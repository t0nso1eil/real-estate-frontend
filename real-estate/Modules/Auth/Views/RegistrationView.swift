//
//  RegistrationView.swift
//  real-estate
//
//  Created by катюшка квакушка on 17.05.2025.
//

// RegistrationView.swift
import SwiftUI

struct RegistrationView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var agreedToTerms: Bool = false
    
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
                
                Text("Создать аккаунт")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    CustomTextField(
                        title: "Имя",
                        placeholder: "Введите ваше имя",
                        text: $name
                    )
                    
                    CustomTextField(
                        title: "Email",
                        placeholder: "Введите ваш email",
                        text: $email,
                        errorMessage: emailError
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    CustomTextField(
                        title: "Пароль",
                        placeholder: "Введите пароль",
                        text: $password,
                        isSecure: true,
                        errorMessage: passwordError
                    )
                    
                    Toggle(isOn: $agreedToTerms) {
                        Text("Я согласен с условиями использования")
                            .font(.system(size: 14))
                            .foregroundColor(.secondaryText)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .accentOrange))
                }
                
                Button(action: register) {
                    Text("Создать аккаунт")
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 32)
                
                HStack {
                    Text("Уже есть аккаунт?")
                        .foregroundColor(.secondaryText)
                    
                    NavigationLink(destination: LoginView()) {
                        Text("Войти")
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
                            Image("google-icon") // Добавьте asset
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        
                        Button(action: {}) {
                            Image("apple-icon") // Добавьте asset
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
    
    private func register() {
        // Валидация
        emailError = nil
        passwordError = nil
        
        if !email.isValidEmail {
            emailError = "Введите корректный email"
            return
        }
        
        if password.count < 6 {
            passwordError = "Пароль должен содержать минимум 6 символов"
            return
        }
        
        if !agreedToTerms {
            // Показать ошибку
            return
        }
        
        // Вызов API регистрации
        print("Регистрация: \(email), \(password)")
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(Color.accentOrange)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: self)
    }
}
