//
//  AuthView.swift
//  real-estate
//
//  Created by катюшка квакушка on 17.05.2025.
//

// AuthView.swift
import SwiftUI

struct AuthView: View {
    @State private var isRegistered = false
    
    var body: some View {
        NavigationView {
            if isRegistered {
                ProfileView()
            } else {
                LoginView()
            }
        }
    }
}
