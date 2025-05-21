import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ProfileView()
                    .environmentObject(authManager)
            } else {
                PredAuthView()
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
    @Published var currentUser: User?
    @Published var authToken: String?
    
    func login(user: User, token: String) {
        self.currentUser = user
        self.authToken = token
        self.isAuthenticated = true
        UserDefaults.standard.set(token, forKey: "authToken")
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    func logout() {
        self.currentUser = nil
        self.authToken = nil
        self.isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func checkAuth() {
        if let token = UserDefaults.standard.string(forKey: "authToken"),
           let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.authToken = token
            self.isAuthenticated = true
        }
    }
}
