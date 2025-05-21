struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let role: String?
    let lastName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, role, lastName
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
