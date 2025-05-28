import Foundation

protocol FavoriteServiceProtocol {
    func toggleFavorite(propertyId: Int) async throws -> Bool
    func checkIsFavorite(propertyId: Int) async throws -> Bool
    func fetchFavoriteProperties() async throws -> [Property]
    func addToFavorites(propertyId: Int) async throws
    func removeFromFavorites(propertyId: Int) async throws
}

class FavoriteService: FavoriteServiceProtocol {
    private let authManager: AuthManager
    private let baseURL: String
    
    init(authManager: AuthManager = .shared, baseURL: String = "http://127.0.0.1:3000") {
        self.authManager = authManager
        self.baseURL = baseURL
    }
    
    // MARK: - Public Methods
    
    func toggleFavorite(propertyId: Int) async throws -> Bool {
        let isFavorite = try await checkIsFavorite(propertyId: propertyId)
        if isFavorite {
            try await removeFromFavorites(propertyId: propertyId)
            return false
        } else {
            try await addToFavorites(propertyId: propertyId)
            return true
        }
    }
    
    func checkIsFavorite(propertyId: Int) async throws -> Bool {
        let favorites = try await fetchFavoriteProperties()
        return favorites.contains { $0.id == propertyId }
    }
    
    func fetchFavoriteProperties() async throws -> [Property] {
        let (data, _) = try await performRequest(
            path: "/api/favorites",
            method: "GET"
        )
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        let responses = try decoder.decode([FavoriteResponse].self, from: data)
        return responses.map { $0.property.toDomainProperty() }
    }
    
    func addToFavorites(propertyId: Int) async throws {
        let body: [String: Any] = ["propertyId": propertyId]
        _ = try await performRequest(
            path: "/api/favorites",
            method: "POST",
            body: body
        )
    }
    
    func removeFromFavorites(propertyId: Int) async throws {
        let favoriteId = try await getFavoriteId(for: propertyId)
        _ = try await performRequest(
            path: "/api/favorites/\(favoriteId)",
            method: "DELETE"
        )
    }
    
    // MARK: - Private Methods
    
    private func getFavoriteId(for propertyId: Int) async throws -> Int {
        let (data, _) = try await performRequest(
            path: "/api/favorites",
            method: "GET"
        )
        
        let responses = try JSONDecoder().decode([FavoriteResponse].self, from: data)
        guard let favorite = responses.first(where: { $0.property.id == propertyId }) else {
            throw URLError(.badURL)
        }
        return favorite.id
    }
    
    private func performRequest(
        path: String,
        method: String,
        body: [String: Any]? = nil
    ) async throws -> (Data, URLResponse) {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        guard let token = authManager.authToken else {
            throw PropertyError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        return try await URLSession.shared.data(for: request)
    }
    
    // MARK: - Response Models
    
    private struct FavoriteResponse: Codable {
        let id: Int
        let property: PropertyResponse
        
        struct PropertyResponse: Codable {
            let id: Int
            let title: String
            let description: String
            let price: String
            let location: String
            let propertyType: String
            let createdAt: String
            let owner: OwnerResponse?
            
            struct OwnerResponse: Codable {
                let id: Int
                let name: String?
                let email: String?
            }
            
            func toDomainProperty() -> Property {
                let priceValue: Double
                if let doubleValue = Double(price), doubleValue.isFinite {
                    priceValue = doubleValue
                } else {
                    priceValue = 0.0
                }
                
                let owner = owner.map { Owner(id: $0.id, name: $0.name, email: $0.email) }
                
                return Property(
                    id: id,
                    title: title,
                    description: description,
                    price: priceValue,
                    location: location,
                    propertyType: propertyType,
                    createdAt: createdAt,
                    owner: owner
                )
            }
        }
    }
}

