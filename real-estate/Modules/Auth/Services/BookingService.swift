import Foundation

class BookingService {
    private let baseURL = "http://localhost:3000/api"
    private let authManager: AuthManager
    
    init(authManager: AuthManager = .shared) {
        self.authManager = authManager
    }
    
    
    func createBookingRequest(_ request: BookingRequest) async throws {
        guard let url = URL(string: "\(baseURL)/booking-requests") else {
            throw PropertyError.invalidURL
        }
        
        guard let token = authManager.authToken else {
            throw PropertyError.unauthorized
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 10
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try encoder.encode(request)
        urlRequest.httpBody = jsonData
        
        printDebugInfo(request: request, jsonData: jsonData)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        printServerResponse(data: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PropertyError.serverError
        }
        
        switch httpResponse.statusCode {
        case 401:
            authManager.logout()
            throw PropertyError.unauthorized
        case 201:
            return
        case 400...499:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw PropertyError.custom(message: errorResponse.message)
            }
            throw PropertyError.custom(message: "Ошибка клиента: \(httpResponse.statusCode)")
        default:
            throw PropertyError.serverError
        }
    }
    
    private func printDebugInfo(request: BookingRequest, jsonData: Data) {
        print("Создаем запрос на бронирование:")
        print("Property ID: \(request.propertyId)")
        print("Tenant ID: \(request.tenantId)")
        print("Даты: \(request.requestedStartDate) - \(request.requestedEndDate)")
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Отправляемый JSON: \(jsonString)")
        }
    }
    
    private func printServerResponse(data: Data) {
        if let responseString = String(data: data, encoding: .utf8) {
            print("Ответ сервера: \(responseString)")
        }
    }
}

struct ErrorResponse: Decodable {
    let message: String
}
