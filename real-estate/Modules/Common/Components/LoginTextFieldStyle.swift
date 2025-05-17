//
//  LoginTextFieldStyle.swift
//  real-estate
//
//  Created by катюшка квакушка on 17.05.2025.
//

import SwiftUI


struct LoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 0.9, green: 0.9, blue: 0.92), lineWidth: 1)
            )
    }
}
