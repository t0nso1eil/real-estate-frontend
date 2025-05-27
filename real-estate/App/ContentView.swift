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

import Foundation

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authToken: String?
    
    static let shared = AuthManager()
    private let tokenKey = "authToken"
    private let userKey = "currentUser"
    
    init() {
        checkAuth()
    }
    
    func login(user: User, token: String) {
        DispatchQueue.main.async {
            self.currentUser = user
            self.authToken = token
            self.isAuthenticated = true
            
            // Сохраняем данные
            UserDefaults.standard.set(token, forKey: self.tokenKey)
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: self.userKey)
            }
            
            // Обновляем заголовки для всех будущих запросов
            URLSession.shared.configuration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(token)"
            ]
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.currentUser = nil
            self.authToken = nil
            self.isAuthenticated = false
            
            // Удаляем сохраненные данные
            UserDefaults.standard.removeObject(forKey: self.tokenKey)
            UserDefaults.standard.removeObject(forKey: self.userKey)
            
            // Очищаем заголовки
            URLSession.shared.configuration.httpAdditionalHeaders?.removeValue(forKey: "Authorization")
        }
    }
    
    func checkAuth() {
        if let token = UserDefaults.standard.string(forKey: tokenKey),
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.authToken = token
                self.isAuthenticated = true
                
                // Устанавливаем заголовок для всех запросов
                URLSession.shared.configuration.httpAdditionalHeaders = [
                    "Authorization": "Bearer \(token)"
                ]
            }
        }
    }
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let token = authToken else {
            completion(false)
            return
        }
        
        // Здесь должна быть логика обновления токена
        // Временно просто возвращаем текущий токен
        completion(true)
    }
    
    func getAuthHeader() -> [String: String]? {
            guard let token = authToken else { return nil }
            return ["Authorization": "Bearer \(token)"]
        }
}
