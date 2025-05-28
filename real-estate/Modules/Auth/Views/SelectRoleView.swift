import SwiftUI

import SwiftUI

struct SelectRoleView: View {
    @State private var selectedRole: String? = nil
    
    var body: some View {
            NavigationView {
                ZStack {
                    Color(red: 0.96, green: 0.96, blue: 0.96)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        ZStack(alignment: .center) {
                            Text("Realstate")
                                .font(.system(size: 40, weight: .heavy))
                                .fontWeight(.black)
                                .foregroundColor(.black)
                            
                            HStack {
                                Spacer()
                                Image("logo")
                                    .resizable()
                                    .frame(width: 51, height: 51)
                                    .offset(x: -20)
                            }
                        }
                        .frame(height: 60)
                        .padding(.top, 40)
                        .padding(.horizontal, 16)
                        
                        ZStack(alignment: .top) {
                            // Лэндлорд (синий блок)
                            VStack(spacing: 20) {
                                Text("Я арендодатель")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                
                                ZStack(alignment: .top) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(red: 0, green: 0.34, blue: 0.72))
                                        .frame(width: 282, height: 110)
                                        .colorMultiply(selectedRole == "tenant" ? .gray : .white) // Фильтр
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedRole = "landlord"
                                        }
                                    }) {
                                        Image("landlord")
                                            .resizable()
                                            .frame(width: 140, height: 140)
                                            .offset(y: -30)
                                            .colorMultiply(selectedRole == "tenant" ? .gray : .white) // Фильтр
                                    }
                                }
                            }
                            .offset(x: 90, y: 30)

                            // Тенант (оранжевый блок)
                            VStack(spacing: 12) {
                                Text("Я арендатор")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                
                                ZStack(alignment: .top) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(red: 1.0, green: 0.58, blue: 0.0))
                                        .frame(width: 282, height: 108)
                                        .colorMultiply(selectedRole == "landlord" ? .gray : .white) // Фильтр
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedRole = "tenant"
                                        }
                                    }) {
                                        Image("tenant")
                                            .resizable()
                                            .frame(width: 138, height: 138)
                                            .offset(y: -30)
                                            .colorMultiply(selectedRole == "landlord" ? .gray : .white) // Фильтр
                                    }
                                }
                            }
                            .offset(x: -90, y: 180)
                        }
                        .frame(height: 320)
                        .padding(.top, 20)

                        Spacer()
                    
                    
                    VStack(spacing: 16) {
                        if let role = selectedRole {
                            NavigationLink {
                                RegistrationView(role: role)
                                    .navigationBarBackButtonHidden(true)
                            } label: {
                                Text("Далее")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color(red: 0, green: 0.34, blue: 0.72))
                                    .cornerRadius(12)
                            }
                        }
                        
                        HStack {
                            Text("Уже есть аккаунт?")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                            
                            NavigationLink {
                                LoginView()
                                    .navigationBarBackButtonHidden(true)
                            } label: {
                                Text("Войти здесь")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0, green: 0.34, blue: 0.72))
                            }
                        }
                        .padding(.top, 8)
                        
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
                        
                        VStack(spacing: 12) {
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
                        .padding(.bottom, 8)
                    }
                    
                    Capsule()
                        .frame(width: 139, height: 5)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .padding(.bottom, 8)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

struct SelectRoleView_Previews: PreviewProvider {
    static var previews: some View {
        SelectRoleView()
    }
}
