//
//  LoginView.swift
//  real-estate
//
//  Created by катюшка квакушка on 17.05.2025.
//

// LoginView.swift
import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    @State private var emailError: String?
    @State private var passwordError: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Логотип (заглушка)
                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.primaryBlue)
                    .padding(.top, 40)
                
                Text("Вход в аккаунт")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    CustomTextField(
                        title: "Email",
                        placeholder: "Введите ваш email",
                        text: $email,
                        errorMessage: emailError
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    ZStack(alignment: .trailing) {
                        if showPassword {
                            CustomTextField(
                                title: "Пароль",
                                placeholder: "Введите пароль",
                                text: $password,
                                errorMessage: passwordError
                            )
                        } else {
                            CustomTextField(
                                title: "Пароль",
                                placeholder: "Введите пароль",
                                text: $password,
                                isSecure: true,
                                errorMessage: passwordError
                            )
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondaryText)
                                .padding(.trailing, 12)
                        }
                    }
                    
                    Button(action: {}) {
                        Text("Забыли пароль?")
                            .font(.system(size: 14))
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                
                Button(action: login) {
                    Text("Войти")
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 32)
                
                HStack {
                    Text("Нет аккаунта?")
                        .foregroundColor(.secondaryText)
                    
                    NavigationLink(destination: RegistrationView()) {
                        Text("Зарегистрироваться")
                            .foregroundColor(.primaryBlue)
                            .fontWeight(.medium)
                    }
                }
                
                // Социальные сети
                VStack(spacing: 16) {
                    Text("Или войдите через")
                        .foregroundColor(.secondaryText)
                        .font(.caption)
                    
                    HStack(spacing: 24) {
                        Button(action: {}) {
                            Image("google-icon")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        
                        Button(action: {}) {
                            Image("apple-icon")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(.systemBackground))
    }
    
    private func login() {
        // Валидация
        emailError = nil
        passwordError = nil
        
        if !email.isValidEmail {
            emailError = "Введите корректный email"
            return
        }
        
        if password.isEmpty {
            passwordError = "Введите пароль"
            return
        }
        
        // Вызов API входа
        print("Вход: \(email), \(password)")
    }
}
