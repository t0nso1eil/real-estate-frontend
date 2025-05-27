import Foundation

protocol PropertyServiceProtocol {
    func fetchProperties() async throws -> [Property]
}

class PropertyService: PropertyServiceProtocol {
    private var errorMessage: String?
    private let baseURL = "http://localhost:3000/api/properties"
    private let authManager: AuthManager
    private let session: URLSession
    
    init(session: URLSession = .shared, authManager: AuthManager = .shared) {
            self.session = session
            self.authManager = authManager
        }
    
    func fetchProperties() async throws -> [Property] {
            guard let url = URL(string: baseURL) else {
                throw PropertyError.invalidURL
            }
            
            guard let token = authManager.authToken else {
                throw PropertyError.unauthorized
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.timeoutInterval = 10
            
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw PropertyError.serverError
                }
                
                switch httpResponse.statusCode {
                case 401:
                    authManager.logout()
                    throw PropertyError.unauthorized
                case 200...299:
                    return try decodeProperties(data: data)
                case 500...599:
                    throw PropertyError.serverError
                default:
                    throw PropertyError.custom(message: "Неизвестная ошибка сервера")
                }
            } catch {
                throw mapError(error)
            }
        }
        
        private func decodeProperties(data: Data) throws -> [Property] {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            
            do {
                var properties = try decoder.decode([Property].self, from: data)
                
                properties = properties.map { property in
                    var validProperty = property
                    if !validProperty.price.isFinite {
                    }
                    return validProperty
                }
                
                return properties
            } catch {
                print("Decoding failed: \(error)")
                throw PropertyError.decodingError(message: "Ошибка обработки данных")
            }
        }
        
        private func mapError(_ error: Error) -> PropertyError {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    return .custom(message: "Нет интернет-соединения")
                case .timedOut:
                    return .custom(message: "Время ожидания истекло")
                default:
                    return .serverError
                }
            }
            return error as? PropertyError ?? .serverError
        }
    
    private func handleDecodingError(_ error: DecodingError) -> PropertyError {
        let message: String
        
        switch error {
        case .dataCorrupted(let context):
            message = "Ошибка в данных: \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            message = "Отсутствует ключ '\(key.stringValue)': \(context.debugDescription)"
        case .valueNotFound(_, let context):
            message = "Отсутствует значение: \(context.debugDescription)"
        case .typeMismatch(let type, let context):
            message = "Тип не совпадает (\(type)): \(context.debugDescription)"
        @unknown default:
            message = "Неизвестная ошибка декодирования"
        }
        
        return PropertyError.decodingError(message: message)
    }
}

enum PropertyError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case serverError
    case decodingError(message: String)
    case custom(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL адрес"
        case .unauthorized: return "Требуется авторизация"
        case .serverError: return "Ошибка сервера"
        case .decodingError(let message): return message
        case .custom(let message): return message
        }
    }
}
