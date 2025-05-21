import Foundation
protocol PropertyServiceProtocol {
    func fetchProperties() async throws -> [Property]
}

class PropertyService: PropertyServiceProtocol {
    private var errorMessage: String?
    private let baseURL = "http://localhost:3000/api/properties"
    private let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE0LCJyb2xlIjoidGVuYW50IiwiaWF0IjoxNzQ3NzkzMDg5LCJleHAiOjE3NDc3OTY2ODl9.vJrrpvjWP_s996PQ7P61Wl_jByADz64j2aaczq0AMXU"
    
    
    func fetchProperties() async throws -> [Property] {
        guard let url = URL(string: baseURL) else {
            throw PropertyError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
                do {
            let decoder = JSONDecoder()
            return try decoder.decode([Property].self, from: data)
        } catch {
            throw handleDecodingError(error as! DecodingError)

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
            message = "Тип не совпадает (\(type)): \(context.debugDescription)" //кидается при ошибке авторизации......
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
    case custom(message: String)  // Добавляем новый case
    
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
