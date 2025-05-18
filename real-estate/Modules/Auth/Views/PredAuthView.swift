import SwiftUI

struct PredAuthView: View {
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
                    
                    Spacer()
                    
                    VStack(spacing: 24) {
                        NavigationLink {
                            SelectRoleView()
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            Text("Создать аккаунт")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(red: 0, green: 0.34, blue: 0.72)) // #0057B8
                                .cornerRadius(12)
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
                    }
                    .padding(.horizontal, 16)
                    
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
                    .padding(.vertical, 32)
                    
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
                    
                    Spacer()
                    
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

struct PredAuthView_Previews: PreviewProvider {
    static var previews: some View {
        PredAuthView()
    }
}
