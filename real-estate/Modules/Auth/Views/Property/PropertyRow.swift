import SwiftUI

struct PropertyRow: View {
    let property: Property

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Заглушка для изображения (замените на реальное изображение)
            Image("apart1")  // Используем имя из Assets
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

                // Цена (крупно)
                Text(property.numericPrice.formatted(.currency(code: "RUB")))
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
