//
//  ProfileView.swift
//  real-estate
//
//  Created by катюшка квакушка on 17.05.2025.
//

// ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @State private var user: User? = User.mock
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок
                HStack {
                    Text("Личный кабинет")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Профиль пользователя
                VStack(spacing: 16) {
                    if let user = user {
                        // Аватар
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.primaryBlue)
                        
                        // Информация
                        VStack(spacing: 4) {
                            Text(user.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.lightBackground)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                
                // Меню
                VStack(spacing: 0) {
                    MenuItem(icon: "list.bullet.rectangle", title: "Мои бронирования") {
                        // Переход к бронированиям
                    }
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    MenuItem(icon: "heart", title: "Избранное") {
                        // Переход к избранному
                    }
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    MenuItem(icon: "gearshape", title: "Настройки") {
                        // Переход к настройкам
                    }
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    MenuItem(icon: "arrow.right.square", title: "Выход", action:  {
                        showingLogoutAlert = true
                    }, isDestructive: true)
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 16)
            }
        }
        .background(Color(.systemGroupedBackground))
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("Выход"),
                message: Text("Вы уверены, что хотите выйти из аккаунта?"),
                primaryButton: .destructive(Text("Выйти")) {
                    // Обработка выхода
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct MenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isDestructive ? .red : .primaryBlue)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : .mainText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
