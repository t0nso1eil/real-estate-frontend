import Foundation
class BookingService {
    private let baseURL = "http://localhost:3000/api"
    private let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE0LCJyb2xlIjoidGVuYW50IiwiaWF0IjoxNzQ3NzkzMDg5LCJleHAiOjE3NDc3OTY2ODl9.vJrrpvjWP_s996PQ7P61Wl_jByADz64j2aaczq0AMXU"
    
    func createBookingRequest(_ request: BookingRequest) async throws {
            guard let url = URL(string: "\(baseURL)/booking-requests") else {
                throw PropertyError.invalidURL
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.keyEncodingStrategy = .useDefaultKeys  // Используем camelCase как в модели
            
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData
            
            // Для отладки
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Отправляемый JSON: \(jsonString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        if let responseString = String(data: data, encoding: .utf8) {
                    print("Ответ сервера: \(responseString)")
                }
            
            // Проверка статус-кода
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PropertyError.serverError
            }
        
        
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw PropertyError.custom(message: errorResponse.message)
                }
                throw PropertyError.serverError
            }
        }
    }

    struct ErrorResponse: Decodable {
        let message: String
    }
