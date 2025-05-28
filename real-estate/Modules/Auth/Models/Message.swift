struct Message: Identifiable, Codable {
    let id: Int
    let content: String
    let createdAt: String
    let sender: User
    let receiver: User
    
    enum CodingKeys: String, CodingKey {
        case id, content, createdAt, sender, receiver
    }
}
