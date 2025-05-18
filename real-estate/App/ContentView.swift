import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ProfileView()
            } else {
                PredAuthView()
            }
        }
        .environmentObject(authManager)
    }
}

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
}
