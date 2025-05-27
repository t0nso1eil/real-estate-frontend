import Foundation

struct Favorite: Codable {
    let id: Int
    let property: FavoriteProperty
    
    struct FavoriteProperty: Codable {
        let id: Int
        let title: String
        let description: String
        let price: String
        let location: String
        let propertyType: String
        
        enum CodingKeys: String, CodingKey {
            case id, title, description, price, location, propertyType
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case property
    }
}

struct UserFavoriteResponse: Codable {
    let id: Int
    let user: User
    let property: Property
    
    struct User: Codable {
        let id: Int
        let firstName: String
        let lastName: String
    }
    
    struct Property: Codable {
        let id: Int
        let title: String
        let price: String
    }
}
