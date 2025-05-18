import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.957, green: 0.957, blue: 0.957)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
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
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Email")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                
                                TextField("Введите ваш email", text: $email)
                                    .textFieldStyle(LoginTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Пароль")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                
                                ZStack(alignment: .trailing) {
                                    if showPassword {
                                        TextField("Введите ваш пароль", text: $password)
                                            .textFieldStyle(LoginTextFieldStyle())
                                    } else {
                                        SecureField("Введите ваш пароль", text: $password)
                                            .textFieldStyle(LoginTextFieldStyle())
                                    }
                                    
                                    Button(action: { showPassword.toggle() }) {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                            .padding(.trailing, 12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 40)
                        
                        Button(action: {}) {
                            Text("Войти")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color(red: 0, green: 0.34, blue: 0.72))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 40)
                        
                        Button(action: {}) {
                            Text("Забыли пароль?")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        }
                        .padding(.top, 16)
                        
                        HStack {
                            Color(red: 0.2, green: 0.2, blue: 0.2)
                                .frame(height: 1)
                            
                            Text("или")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .padding(.horizontal, 8)
                            
                            Color(red: 0.2, green: 0.2, blue: 0.2)
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        
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
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(false)
        }
        .navigationViewStyle(.stack)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
