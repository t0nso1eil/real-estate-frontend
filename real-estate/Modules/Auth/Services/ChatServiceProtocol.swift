import Foundation


protocol ChatServiceProtocol {
    func fetchChat(chatId: Int) async throws -> Chat
    func sendMessage(chatId: Int, content: String, receiverId: Int) async throws -> Message
}

class ChatService: ChatServiceProtocol {
    private var errorMessage: String?
    private let baseURL = "http://localhost:3000/api/chats"
    private let authManager: AuthManager
    private let session: URLSession
    
    init(session: URLSession = .shared, authManager: AuthManager = .shared) {
        self.session = session
        self.authManager = authManager
    }
    
    func fetchChat(chatId: Int) async throws -> Chat {
        guard let url = URL(string: "\(baseURL)/\(chatId)") else {
            throw ChatError.invalidURL
        }
        
        guard let token = authManager.authToken else {
            throw ChatError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatError.serverError
            }
            
            switch httpResponse.statusCode {
            case 401:
                authManager.logout()
                throw ChatError.unauthorized
            case 200...299:
                let decoder = JSONDecoder()
                return try decoder.decode(Chat.self, from: data)
            case 500...599:
                throw ChatError.serverError
            default:
                throw ChatError.custom(message: "Неизвестная ошибка сервера")
            }
        } catch {
            throw mapError(error)
        }
    }
    
    func sendMessage(chatId: Int, content: String, receiverId: Int) async throws -> Message {
        guard let url = URL(string: "\(baseURL)/\(chatId)/messages") else {
            throw ChatError.invalidURL
        }
        
        guard let token = authManager.authToken else {
            throw ChatError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let requestBody: [String: Any] = [
            "content": content,
            "receiverId": receiverId
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatError.serverError
            }
            
            switch httpResponse.statusCode {
            case 401:
                authManager.logout()
                throw ChatError.unauthorized
            case 200...299:
                let decoder = JSONDecoder()
                return try decoder.decode(Message.self, from: data)
            case 500...599:
                throw ChatError.serverError
            default:
                throw ChatError.custom(message: "Неизвестная ошибка сервера")
            }
        } catch {
            throw mapError(error)
        }
    }
    
    private func mapError(_ error: Error) -> ChatError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            default:
                return .serverError
            }
        } else if error is DecodingError {
            return .decodingError
        } else if let chatError = error as? ChatError {
            return chatError
        } else {
            return .custom(message: error.localizedDescription)
        }
    }
}

enum ChatError: Error {
    case invalidURL
    case unauthorized
    case serverError
    case noInternetConnection
    case timeout
    case decodingError
    case custom(message: String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .unauthorized:
            return "Необходима авторизация"
        case .serverError:
            return "Ошибка сервера"
        case .noInternetConnection:
            return "Нет подключения к интернету"
        case .timeout:
            return "Время ожидания истекло"
        case .decodingError:
            return "Ошибка обработки данных"
        case .custom(let message):
            return message
        }
    }
}
