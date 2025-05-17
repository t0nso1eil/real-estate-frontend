//
//  ContentView.swift
//  real-estate
//
//  Created by катюшка квакушка on 17.05.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ProfileView()
            } else {
                AuthView()
            }
        }
        .environmentObject(authManager)
    }
}

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
}
