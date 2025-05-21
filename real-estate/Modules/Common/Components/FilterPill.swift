import SwiftUI

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

