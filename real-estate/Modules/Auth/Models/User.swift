struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let role: String?
    let lastName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, role, lastName
        case firstName
    }
    
    init(id: Int, name: String, email: String, role: String?, lastName: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.lastName = lastName
    }
    
    init(from finalUser: FinalUser) {
        self.id = finalUser.id
        self.name = finalUser.name
        self.email = finalUser.email
        self.role = finalUser.role
        self.lastName = finalUser.lastName
    }
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decode(Int.self, forKey: .id)
            email = try container.decode(String.self, forKey: .email)
            role = try container.decodeIfPresent(String.self, forKey: .role)
            lastName = try container.decodeIfPresent(String.self, forKey: .lastName)

            // Пробуем сначала name, если нет — берем firstName
            if let nameValue = try? container.decode(String.self, forKey: .name) {
                name = nameValue
            } else if let firstNameValue = try? container.decode(String.self, forKey: .firstName) {
                name = firstNameValue
            } else {
                throw DecodingError.keyNotFound(
                    CodingKeys.name,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Neither 'name' nor 'firstName' was found"
                    )
                )
            }
        }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name) // Используем name как основное поле
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(role, forKey: .role)
        try container.encodeIfPresent(lastName, forKey: .lastName)
    }

    
    static let mock = User(
        id: 1,
        name: "Иван Иванов",
        email: "ivan@example.com",
        role: "user",
        lastName: "Иванов"
    )
}


struct FinalUser: Codable {
    let id: Int
    let name: String
    let lastName: String?
    let email: String
    let role: String?
}
