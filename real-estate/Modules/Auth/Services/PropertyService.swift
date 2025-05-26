import Foundation

protocol PropertyServiceProtocol {
    func fetchProperties() async throws -> [Property]
}

class PropertyService: PropertyServiceProtocol {
    private var errorMessage: String?
    private let baseURL = "http://localhost:3000/api/properties"
    private let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJ0ZW5hbnQiLCJpYXQiOjE3NDgyODg4MzcsImV4cCI6MTc0ODI5MjQzN30.mcaxoa2EXE0foz26EwMnu_H2hGmdyor32m35gNPpY_c"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchProperties() async throws -> [Property] {
            guard let url = URL(string: baseURL) else {
                throw PropertyError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw PropertyError.serverError
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            
            do {
                return try decoder.decode([Property].self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw PropertyError.decodingError(message: "Ошибка обработки данных: \(error.localizedDescription)")
            }
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
