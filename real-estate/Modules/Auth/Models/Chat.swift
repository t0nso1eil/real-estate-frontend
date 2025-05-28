//
//  Chat.swift
//  real-estate
//
//  Created by катюшка квакушка on 28.05.2025.
//


// Модель чата
struct Chat: Codable, Identifiable {
    let id: Int
    var messages: [Message]
    let property: Property
    let tenant: User
    let landlord: User


}
