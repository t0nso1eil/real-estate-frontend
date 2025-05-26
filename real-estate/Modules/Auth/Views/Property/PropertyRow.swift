import SwiftUI

struct PropertyRow: View {
    let property: Property
    
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₽"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter.string(from: NSNumber(value: property.safePrice)) ?? "\(Int(property.safePrice)) ₽"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("apart1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .overlay(
                    HStack {
                        Text(property.propertyType.capitalized)
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        Spacer()
                    }
                    .padding(8),
                    alignment: .topLeading
                )

            VStack(alignment: .leading, spacing: 8) {
                // Название
                Text(property.title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)

                // Цена (крупно) с рублями
                Text(formattedPrice)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)

                // Адрес
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                    Text(property.location)
                        .font(.system(size: 14))
                }
                .foregroundColor(.gray)
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
