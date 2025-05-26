struct Owner: Decodable {
    let id: Int
    let name: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
    }
}

struct Property: Identifiable, Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let location: String
    let propertyType: String
    let createdAt: String
    let owner: Owner?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, price, location
        case propertyType
        case createdAt
        case owner
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        
        if let stringPrice = try? container.decode(String.self, forKey: .price),
           let doubleValue = Double(stringPrice), doubleValue.isFinite {
            price = doubleValue
        } else {
            price = (try? container.decode(Double.self, forKey: .price)) ?? 0.0
        }
        
        location = try container.decode(String.self, forKey: .location)
        propertyType = try container.decode(String.self, forKey: .propertyType)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        owner = try container.decodeIfPresent(Owner.self, forKey: .owner)
    }
    
    var safePrice: Double {
        price.isFinite ? price : 0.0
    }
}
