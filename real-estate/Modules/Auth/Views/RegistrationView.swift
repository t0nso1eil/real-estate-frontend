import SwiftUI

struct RegistrationView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var birthDate: String = ""
    @State private var password: String = ""
    @State private var agreedToTerms: Bool = false
    
    var body: some View {
        ZStack {
            Color(red: 0.957, green: 0.957, blue: 0.957)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with logo
                    ZStack(alignment: .center) {
                        Text("Realstate")
                            .font(.system(size: 40, weight: .heavy))
                            .fontWeight(.black)
                            .foregroundColor(.black)
                            .alignmentGuide(.top) { d in d[.bottom] - 25 }
                        
                        HStack {
                            Spacer()
                            Image("logo")
                                .resizable()
                                .frame(width: 51, height: 51)
                                .alignmentGuide(.top) { d in d[.bottom] - 25.5 }
                                .offset(x: -20)
                        }
                    }
                    .frame(height: 60)
                    .padding(.top, 60)
                    .padding(.horizontal, 16)
                    
                    Text("Создать аккаунт")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.top, 24)
                    
                    // Form fields
                    VStack(spacing: 16) {
                        // Name fields in a row
                        HStack(spacing: 16) {
                            CustomTextField(
                                title: "Имя",
                                placeholder: "",
                                text: $firstName
                            )
                            
                            CustomTextField(
                                title: "Фамилия",
                                placeholder: "",
                                text: $lastName
                            )
                        }
                        .padding(.top, 32)
                        
                        CustomTextField(
                            title: "Email",
                            placeholder: "",
                            text: $email
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        
                        CustomTextField(
                            title: "Номер телефона",
                            placeholder: "",
                            text: $phoneNumber
                        )
                        .keyboardType(.phonePad)
                        
                        CustomTextField(
                            title: "Дата рождения",
                            placeholder: "",
                            text: $birthDate
                        )
                        
                        CustomTextField(
                            title: "Пароль",
                            placeholder: "",
                            text: $password,
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Terms checkbox
                    HStack {
                        Button(action: {
                            agreedToTerms.toggle()
                        }) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreedToTerms ? .blue : .gray)
                        }
                        
                        Text("Согласен с условиями")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 16)
                    
                    // Next button (blue)
                    Button(action: {}) {
                        Text("Далее")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(red: 0, green: 0.34, blue: 0.72)) // #0057B8
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 32)
                    
                    // Already have account
                    Text("Уже есть аккаунт? Войти здесь")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.top, 32)
                    
                    // Or divider
                    HStack {
                        Color(red: 0.2, green: 0.2, blue: 0.2)
                            .frame(height: 1)
                        
                        Text("или")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .padding(.horizontal, 8)
                        
                        Color(red: 0.2, green: 0.2, blue: 0.2)
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 32)
                    
                    // Social buttons
                    VStack(spacing: 16) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .foregroundColor(.white)
                                Text("Войти через Apple")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image("google-icon")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Войти через Google")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
