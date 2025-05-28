//
//  Message.swift
//  real-estate
//
//  Created by катюшка квакушка on 28.05.2025.
//

import Foundation


// Модель сообщения
struct Message: Codable, Identifiable {
    let id: Int
    let content: String
    let createdAt: String
    let sender: User
    let receiver: User
    
    var formattedDate: String {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: createdAt) else { return createdAt }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .short
        outputFormatter.timeStyle = .short
        return outputFormatter.string(from: date)
    }
}

