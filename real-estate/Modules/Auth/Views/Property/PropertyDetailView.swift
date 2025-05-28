import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @State private var showingBookingRequest = false
    @State private var showingChatView = false
    @State private var ownerDetails: User?
    @State private var isLoadingOwner = false
    @State private var errorMessage: String?
    
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image("apart1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(property.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("\(Int(property.price)) ₽/мес")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#0057B8"))
                        
                        Spacer()
                        
                        Text(property.propertyType)
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(property.location)
                    }
                    .foregroundColor(.secondary)
                }
                
                Divider()
                
                Text("Описание")
                    .font(.headline)
                
                Text(property.description)
                
                Button(action: {
                    showingBookingRequest = true
                }) {
                    Text("Создать заявку")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0057B8"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.vertical)
                .sheet(isPresented: $showingBookingRequest) {
                    CreateBookingRequestView(property: property)
                }
                
                if let owner = property.owner {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Арендодатель")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#FA8A00"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            
                            Spacer()
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        HStack(alignment: .top, spacing: 16) {
                            Image("profile")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if isLoadingOwner {
                                    ProgressView()
                                } else {
                                    // Объединенное ФИО в одну строку
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text(ownerDetails?.lastName ?? "")
                                            .font(.system(size: 24, weight: .bold))
                                        Text(ownerDetails?.name ?? owner.name ?? "Не указано")
                                            .font(.system(size: 24, weight: .bold))
                                    }
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(1)
                                }
                                
                                if let email = ownerDetails?.email ?? owner.email {
                                    Text(email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Кнопка "Написать" с NavigationLink
                        NavigationLink(destination: ChatView(propertyId: property.id), isActive: $showingChatView) {
                            Button(action: {
                                showingChatView = true
                            }) {
                                Text("Написать")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "#0057B8"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(action: {
                            // Действие для жалобы
                        }) {
                            Text("Пожаловаться")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.red)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.top, 8)
                    .onAppear {
                        fetchOwnerDetails(ownerId: owner.id)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(property.title)
    }
    
    private func fetchOwnerDetails(ownerId: Int) {
        guard authManager.isAuthenticated, let token = authManager.authToken else {
            errorMessage = "Требуется авторизация"
            return
        }
        
        isLoadingOwner = true
        errorMessage = nil
        
        guard let url = URL(string: "http://localhost:3000/api/users/\(ownerId)") else {
            isLoadingOwner = false
            errorMessage = "Неверный URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoadingOwner = false
                
                if let error = error {
                    errorMessage = "Ошибка: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "Нет данных в ответе"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedResponse = try decoder.decode(User.self, from: data)
                    ownerDetails = decodedResponse
                } catch {
                    errorMessage = "Ошибка декодирования: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
