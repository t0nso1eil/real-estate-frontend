/* import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ProfileView()
                    .environmentObject(authManager)
            } else {
                SelectRoleView()
                    .environmentObject(authManager)
            }
        }
        .environmentObject(authManager)
        .onAppear {
            authManager.checkAuth()
        }
    }
}

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var authToken: String?
    
    func login(user: User, token: String) {
        self.user = user
        self.authToken = token
        self.isAuthenticated = true
        // Сохраняем в UserDefaults или Keychain
        UserDefaults.standard.set(token, forKey: "authToken")
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    func logout() {
        self.user = nil
        self.authToken = nil
        self.isAuthenticated = false
        // Удаляем из UserDefaults
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func checkAuth() {
        if let token = UserDefaults.standard.string(forKey: "authToken"),
           let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = user
            self.authToken = token
            self.isAuthenticated = true
        }
    }
}
*/
