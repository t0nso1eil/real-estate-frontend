struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let role: String?
    let lastName: String?
    
    static let mock = User(
        id: 1,
        name: "Иван Иванов",
        email: "ivan@example.com",
        role: "user",
        lastName: "Иванов"
    )
}
