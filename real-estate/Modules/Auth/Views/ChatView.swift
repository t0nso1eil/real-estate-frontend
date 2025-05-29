import SwiftUI

struct ChatView: View {
    let propertyId: Int
    @State private var chat: Chat?
    @State private var isLoading = false
    @State private var isLoadingOwner = false
    @State private var errorMessage: String?
    @State private var newMessageText = ""
    @State private var ownerDetails: User?
    @State private var isCreatingChat = false
    @State private var isSendingMessage = false
    @State private var lastUpdate = Date()
    
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    
    // Таймер для автоматического обновления чата
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // Шапка чата
            VStack(spacing: 0) {
                // Кнопка назад и заголовок
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Text("Чат")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                
                // Информация о владельце и недвижимости
                if let property = chat?.property, let owner = chat?.property.owner {
                    HStack(alignment: .top, spacing: 12) {
                        // Аватар владельца
                        Image("profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        
                        // Информация о владельце
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                if isLoadingOwner {
                                    ProgressView()
                                } else {
                                    Text(ownerDetails?.name ?? owner.name ?? "Не указано")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                
                                Text("арендодатель")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(hex: "#FA8A00"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color(hex: "#FA8A00"), lineWidth: 1)
                                    )
                            }
                            
                            // Карточка с информацией о недвижимости
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "#0057B8"))
                                    .frame(height: 55)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(property.title)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text(property.location)
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(Int(property.price)) ₽")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(hex: "#F4F4F4"))
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .onAppear {
                        fetchOwnerDetails(ownerId: owner.id)
                    }
                }
            }
            .background(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Основное содержимое чата
            Group {
                if isLoading || isCreatingChat {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack {
                        Text("Произошла ошибка")
                            .font(.headline)
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Повторить") {
                            fetchOrCreateChat()
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else if let chat = chat {
                    ChatMessagesView(
                        chat: chat,
                        currentUserId: authManager.currentUser?.id,
                        onRefresh: refreshChat
                    )
                } else {
                    Text("Создание чата...")
                        .frame(maxHeight: .infinity)
                }
            }
            .background(Color(hex: "#F4F4F4"))
            
            // Поле ввода сообщения
            HStack {
                TextField("Написать сообщение...", text: $newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isSendingMessage)
                
                if isSendingMessage {
                    ProgressView()
                } else {
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(newMessageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(newMessageText.isEmpty)
                }
            }
            .padding()
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchOrCreateChat()
        }
        .onReceive(timer) { _ in
            if chat != nil {
                refreshChat()
            }
        }
    }
    
    
    private func sendMessage() {
        guard let chatId = chat?.id, !newMessageText.isEmpty else {
            print("Ошибка: chatId = \(chat?.id ?? nil), newMessageText = \(newMessageText)")
            return
        }
        
        isSendingMessage = true
        
        guard let token = authManager.authToken else {
            errorMessage = "Требуется авторизация"
            isSendingMessage = false
            print("Ошибка: отсутствует токен авторизации")
            return
        }
        
        let urlString = "http://localhost:3000/api/chats/\(chatId)/message"
        guard let url = URL(string: urlString) else {
            errorMessage = "Неверный URL"
            isSendingMessage = false
            print("Ошибка: неверный URL - \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["content": newMessageText]
        print("Отправляемые данные: \(requestBody)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("Тело запроса: \(bodyString)")
            }
        } catch {
            errorMessage = "Ошибка создания запроса: \(error.localizedDescription)"
            isSendingMessage = false
            print("Ошибка сериализации JSON: \(error)")
            return
        }
        
        print("Отправка запроса на \(urlString)")
        print("Заголовки: \(request.allHTTPHeaderFields ?? [:])")
        
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            DispatchQueue.main.async {
                self.isSendingMessage = false
                
                if let error = error {
                    self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
                    print("Ошибка сети: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Некорректный ответ сервера"
                    print("Ошибка: некорректный ответ сервера")
                    return
                }
                
                print("Статус код: \(httpResponse.statusCode)")
                print("Заголовки ответа: \(httpResponse.allHeaderFields)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Тело ответа: \(responseString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Ошибка сервера: статус \(httpResponse.statusCode)"
                    print("Ошибка сервера: статус \(httpResponse.statusCode)")
                    return
                }
                
                self.newMessageText = ""
                self.refreshChat()
                print("Сообщение успешно отправлено")
            }
        }.resume()
    }
    
    private func refreshChat() {
        guard let chatId = chat?.id else {
            print("Ошибка: chatId отсутствует")
            return
        }
        
        let urlString = "http://localhost:3000/api/chats/\(chatId)"
        print("Обновление чата: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Неверный URL"
            print("Ошибка: неверный URL - \(urlString)")
            return
        }
        
        guard let token = authManager.authToken else {
            errorMessage = "Требуется авторизация"
            print("Ошибка: отсутствует токен авторизации")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("Запрос на обновление чата: \(request)")
        
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка обновления чата: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Некорректный ответ сервера при обновлении чата")
                    return
                }
                
                print("Статус код обновления чата: \(httpResponse.statusCode)")
                
                guard let data = data else {
                    print("Нет данных при обновлении чата")
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Ответ обновления чата: \(responseString)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let updatedChat = try decoder.decode(Chat.self, from: data)
                    self.chat = updatedChat
                    self.lastUpdate = Date()
                    print("Чат успешно обновлен")
                } catch {
                    print("Ошибка декодирования чата: \(error.localizedDescription)")
                    print("Полный текст ошибки: \(error)")
                }
            }
        }.resume()
    }
    
    private func fetchOrCreateChat() {
        guard authManager.isAuthenticated, let token = authManager.authToken else {
            errorMessage = "Требуется авторизация"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        fetchChats { chats in
            if let existingChat = chats.first(where: { $0.property.id == self.propertyId }) {
                DispatchQueue.main.async {
                    self.chat = existingChat
                    self.isLoading = false
                }
            } else {
                self.createChat()
            }
        }
    }
    
    private func fetchChats(completion: @escaping ([Chat]) -> Void) {
        guard let token = authManager.authToken else {
            errorMessage = "Требуется авторизация"
            isLoading = false
            return
        }
        
        guard let url = URL(string: "http://localhost:3000/api/chats") else {
            errorMessage = "Неверный URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Нет данных в ответе"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let chats = try decoder.decode([Chat].self, from: data)
                    completion(chats)
                } catch {
                    self.errorMessage = "Ошибка декодирования: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func createChat() {
        guard let token = authManager.authToken else {
            errorMessage = "Требуется авторизация"
            isLoading = false
            isCreatingChat = false
            return
        }
        
        isCreatingChat = true
        errorMessage = nil
        
        guard let url = URL(string: "http://localhost:3000/api/chats") else {
            errorMessage = "Неверный URL"
            isLoading = false
            isCreatingChat = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["propertyId": propertyId]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            errorMessage = "Ошибка создания запроса: \(error.localizedDescription)"
            isLoading = false
            isCreatingChat = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                self.isCreatingChat = false
                
                if let error = error {
                    self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Ошибка сервера"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Нет данных в ответе"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let newChat = try decoder.decode(Chat.self, from: data)
                    self.chat = newChat
                    self.errorMessage = nil
                } catch {
                    self.fetchChats { chats in
                        DispatchQueue.main.async {
                            if let existingChat = chats.first(where: { $0.property.id == self.propertyId }) {
                                self.chat = existingChat
                                self.errorMessage = nil
                            } else {
                                self.errorMessage = "Не удалось загрузить чат"
                            }
                        }
                    }
                }
            }
        }.resume()
    }
    
    private func fetchOwnerDetails(ownerId: Int) {
        guard authManager.isAuthenticated, let token = authManager.authToken else {
            errorMessage = "Требуется авторизация"
            return
        }
        
        isLoadingOwner = true
        errorMessage = nil
        
        guard let url = URL(string: "http://localhost:3000/api/users/\(ownerId)") else {
            isLoadingOwner = false
            errorMessage = "Неверный URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingOwner = false
                
                if let error = error {
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Нет данных в ответе"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedResponse = try decoder.decode(User.self, from: data)
                    self.ownerDetails = decodedResponse
                } catch {
                    self.errorMessage = "Ошибка декодирования: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct ChatMessagesView: View {
    let chat: Chat
    let currentUserId: Int?
    let onRefresh: () -> Void
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if chat.messages.isEmpty {
                        Text("Нет сообщений")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ForEach(chat.messages) { message in
                            MessageView(
                                message: message,
                                isCurrentUser: message.sender.id == currentUserId
                            )
                        }
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
            }
            .background(Color(hex: "#F4F4F4"))
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: chat.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .refreshable {
                onRefresh()
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = chat.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

struct MessageView: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Text(formatDate(message.createdAt))
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Text(formatDate(message.createdAt))
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 16)
                
                Spacer()
            }
        }
        .id(message.id)
        .transition(.opacity)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
}
