import SwiftUI

struct ChatView: View {
    let propertyId: Int
    @State private var chat: Chat?
    @State private var chatId: Int?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var newMessageText = ""
    @State private var currentUser: User? = AuthManager.shared.currentUser
    
    private let chatService = ChatService()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if let chat = chat {
                chatHeader(chat: chat)
                messagesList(chat: chat)
                messageInput
            } else {
                Text("Чат не найден")
            }
        }
        .navigationTitle("Чат")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadOrCreateChat()
        }
    }
    
    // MARK: - Chat Loading/Creation Logic
    
    private func loadOrCreateChat() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Получаем все чаты пользователя
            let allChats = try await fetchAllChats()
            // 2. Ищем чат с нужной propertyId
            if let existingChat = allChats.first(where: { $0.property.id == propertyId }) {
                chat = existingChat
                chatId = existingChat.id
            }
            // 3. Если чата нет - создаём новый
            else {
                let newChat = try await createNewChat()
                chat = newChat
                chatId = newChat.id
            }
        } catch {
            errorMessage = (error as? ChatError)?.localizedDescription ?? "Ошибка при загрузке чата"
        }
        
        isLoading = false
    }
    
    private func fetchAllChats() async throws -> [Chat] {
        guard currentUser != nil else {
            print("❌ Ошибка: текущий пользователь не найден")
            throw ChatError.unauthorized
        }
        
        guard let token = AuthManager.shared.authToken else {
            print("❌ Ошибка: токен авторизации отсутствует")
            throw ChatError.unauthorized
        }
        
        let urlString = "http://localhost:3000/api/chats"
        print("🌐 Запрос всех чатов")
        print("🔗 URL: \(urlString)")
        print("🔐 Токен: Bearer \(token)")

        guard let url = URL(string: urlString) else {
            print("❌ Ошибка: некорректный URL")
            throw ChatError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        print("📤 Заголовки запроса: \(request.allHTTPHeaderFields ?? [:])")
        print("📤 Тело запроса: \(request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "пустое")")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Ошибка: не удалось получить HTTP-ответ")
                throw ChatError.serverError
            }

            print("📥 HTTP-код ответа: \(httpResponse.statusCode)")
            
            if let body = String(data: data, encoding: .utf8) {
                print("📦 Тело ответа: \(body)")
            } else {
                print("📦 Тело ответа: невозможно прочитать как строку")
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let chats = try JSONDecoder().decode([Chat].self, from: data)
                    print("✅ Успешно декодировано \(chats.count) чатов")
                    return chats
                } catch {
                    print("❌ Ошибка при декодировании JSON: \(error)")
                    throw error
                }
            case 401:
                print("⚠️ Ошибка авторизации (401). Выход из аккаунта.")
                AuthManager.shared.logout()
                throw ChatError.unauthorized
            default:
                print("❌ Ошибка сервера: код \(httpResponse.statusCode)")
                throw ChatError.serverError
            }
        } catch {
            print("❌ Ошибка при выполнении запроса: \(error.localizedDescription)")
            throw error
        }
    }

    private func createNewChat() async throws -> Chat {
        guard let currentUser = currentUser else {
            throw ChatError.unauthorized
        }
        
        // Получаем информацию о недвижимости
        let property = try await fetchPropertyDetails()
        
        // Убеждаемся, что у property есть владелец
        guard let ownerId = property.owner?.id else {
            throw ChatError.custom(message: "Не удалось определить владельца недвижимости")
        }
        
        let url = URL(string: "http://localhost:3000/api/chats")!
        
        guard let token = AuthManager.shared.authToken else {
            throw ChatError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Определяем роли участников чата
        let isLandlord = currentUser.role == "landlord"
        let requestBody: [String: Any] = [
            "propertyId": propertyId,
            "tenantId": isLandlord ? nil : currentUser.id,
            "landlordId": isLandlord ? currentUser.id : ownerId
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Chat.self, from: data)
    }
    
    private func fetchPropertyDetails() async throws -> Property {
        guard let token = AuthManager.shared.authToken else {
            throw ChatError.unauthorized
        }
        
        let url = URL(string: "http://localhost:3000/api/properties/\(propertyId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatError.serverError
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(Property.self, from: data)
        case 401:
            AuthManager.shared.logout()
            throw ChatError.unauthorized
        default:
            throw ChatError.serverError
        }
    }
    
    
    private func chatHeader(chat: Chat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(chat.property.title)
                .font(.headline)
            
            HStack {
                Text("Арендатор: \(chat.tenant.name)")
                Spacer()
                Text("Арендодатель: \(chat.landlord.name)")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func messagesList(chat: Chat) -> some View {
        ScrollViewReader { proxy in
            List {
                ForEach(chat.messages) { message in
                    messageView(message: message)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .id(message.id)
                }
            }
            .listStyle(.plain)
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: chat.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    private func messageView(message: Message) -> some View {
        HStack {
            if isCurrentUser(message.sender) {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Text(message.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.sender.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(message.content)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    
                    Text(message.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
    }
    
    private var messageInput: some View {
        HStack {
            TextField("Введите сообщение...", text: $newMessageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                Task { await sendMessage() }
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
            }
            .disabled(newMessageText.isEmpty)
        }
        .padding()
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = chat?.messages.last {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
    
    private func isCurrentUser(_ user: User) -> Bool {
        return user.id == currentUser?.id
    }
    
    // MARK: - Network Methods
    
    private func fetchChat() async {
        isLoading = true
        errorMessage = nil
        
        do {
            chat = try await chatService.fetchChat(chatId: chatId ?? 1)
        } catch {
            errorMessage = (error as? ChatError)?.localizedDescription ?? "Неизвестная ошибка"
        }
        
        isLoading = false
    }
    
    private func sendMessage() async {
        guard !newMessageText.isEmpty, let chat = chat else { return }
        
        let receiverId = currentUser?.id == chat.tenant.id ? chat.landlord.id : chat.tenant.id
        
        do {
            let message = try await chatService.sendMessage(
                chatId: chatId ?? 1,
                content: newMessageText,
                receiverId: receiverId
            )
            
            self.chat?.messages.append(message)
            newMessageText = ""
        } catch {
            errorMessage = (error as? ChatError)?.localizedDescription ?? "Ошибка при отправке сообщения"
        }
    }
}

// MARK: - Models and Services

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(propertyId: 13)
    }
}
