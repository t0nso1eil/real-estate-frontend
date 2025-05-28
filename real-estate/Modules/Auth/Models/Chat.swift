import SwiftUICore
struct Chat: Identifiable, Codable {
    let id: Int
    let messages: [Message]
    let property: Property
}
