import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLogoutAlert = false
    
    private var fullName: String {
        guard let user = authManager.currentUser else { return "" }
        if let lastName = user.lastName {
            return "\(user.name) \(lastName)"
        }
        return user.name
    }
    
    private var roleDescription: String {
        guard let role = authManager.currentUser?.role else { return "Пользователь" }
        switch role.lowercased() {
        case "landlord": return "Арендодатель"
        case "tenant": return "Арендатор"
        case "admin": return "Администратор"
        default: return "Пользователь"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Заголовок
                    HStack {
                        Text("Личный кабинет")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Информация о пользователе
                    if let user = authManager.currentUser {
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.blue)
                            
                            VStack(spacing: 4) {
                                Text(fullName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(roleDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                    
                    // Меню
                    VStack(spacing: 0) {
                        MenuItem(icon: "list.bullet.rectangle", title: "Мои бронирования") {
                            // Действие для бронирований
                        }
                        
                        Divider().padding(.leading, 56)
                        
                        MenuItem(icon: "heart", title: "Избранное") {
                            // Действие для избранного
                        }
                        
                        Divider().padding(.leading, 56)
                        
                        MenuItem(icon: "gearshape", title: "Настройки") {
                            // Действие для настроек
                        }
                        
                        Divider().padding(.leading, 56)
                        
                        MenuItem(
                            icon: "arrow.right.square",
                            title: "Выход",
                            action: { showingLogoutAlert = true },
                            isDestructive: true
                        )
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Выход"),
                    message: Text("Вы уверены, что хотите выйти из аккаунта?"),
                    primaryButton: .destructive(Text("Выйти")) {
                        authManager.logout()
                        // Возвращаемся на предыдущий экран после выхода
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct MenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isDestructive ? .red : .blue)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : .primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthManager()
        authManager.currentUser = User.mock
        
        return ProfileView()
            .environmentObject(authManager)
    }
}
