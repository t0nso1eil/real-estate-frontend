import SwiftUI

struct PropertyRow: View {
    let property: Property
    @State private var isFavorite: Bool = false
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    private let favoriteService: FavoriteServiceProtocol
    
    init(property: Property, favoriteService: FavoriteServiceProtocol = FavoriteService()) {
        self.property = property
        self.favoriteService = favoriteService
    }
    
    private var safeDisplayPrice: Double {
        let price = property.safePrice
        return price.isFinite ? price : 0
    }
    
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₽"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter.string(from: NSNumber(value: safeDisplayPrice)) ?? "\(Int(safeDisplayPrice)) ₽"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let imageHeight: CGFloat = 200.0
            
            Image("apart1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: imageHeight)
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
                        
                        // Кнопка избранного
                        Button(action: toggleFavorite) {
                                                if isLoading {
                                                    ProgressView()
                                                        .frame(width: 20, height: 20)
                                                } else {
                                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                                        .font(.system(size: 20))
                                                }
                                            }
                                            .foregroundColor(isFavorite ? .red : .white)
                                            .padding(8)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                        }
                                        .padding(8),
                    alignment: .topLeading
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(property.title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)

                Text(formattedPrice)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)

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
        .shadow(color: Color.black.opacity(max(0.1, 0)), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onAppear {
                    checkInitialFavoriteStatus()
                }
                .alert("Ошибка", isPresented: $showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
    }
    
    private func checkInitialFavoriteStatus() {
            Task {
                do {
                    let isFavorite = try await favoriteService.checkIsFavorite(propertyId: property.id)
                    await MainActor.run {
                        self.isFavorite = isFavorite
                    }
                } catch {
                    print("Failed to check favorite status: \(error)")
                }
            }
        }
    
    private func toggleFavorite() {
            Task {
                await MainActor.run {
                    isLoading = true
                    showError = false
                }
                
                do {
                    let newStatus = try await favoriteService.toggleFavorite(propertyId: property.id)
                    await MainActor.run {
                        isFavorite = newStatus
                        isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
    
    private func parseError(_ error: Error) -> String {
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    return "Ошибка данных: \(context.debugDescription)"
                case .keyNotFound(let key, _):
                    return "Отсутствует поле: \(key.stringValue)"
                case .typeMismatch(let type, _):
                    return "Несоответствие типа: \(type)"
                case .valueNotFound(let type, _):
                    return "Отсутствует значение: \(type)"
                @unknown default:
                    return "Неизвестная ошибка декодирования"
                }
            }
            return error.localizedDescription
        }
}
