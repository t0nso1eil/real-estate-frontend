import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var favorites: [Property] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let favoriteService: FavoriteServiceProtocol = FavoriteService()
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text("Ошибка: \(errorMessage)")
                            .foregroundColor(.red)
                        Button("Повторить") {
                            loadFavorites()
                        }
                    }
                } else if favorites.isEmpty {
                    VStack {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                            .padding()
                        Text("В избранном пока ничего нет")
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(favorites) { property in
                                NavigationLink(destination: PropertyDetailView(property: property)) {
                                    PropertyRow(property: property)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Избранное")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadFavorites()
            }
        }
    }
    
    private func loadFavorites() {
            Task {
                await MainActor.run {
                    isLoading = true
                    errorMessage = nil
                }
                
                do {
                    let properties = try await favoriteService.fetchFavoriteProperties()
                    await MainActor.run {
                        favorites = properties
                        isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        isLoading = false
                    }
                }
        }
    }
}

