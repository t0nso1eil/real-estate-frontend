import SwiftUI

struct ChatView: View {
    let propertyId: Int
    @State private var chat: Chat?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var newMessageText = ""
    @State private var rawResponse: String = ""
    
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            // Заголовок чата с кнопкой назад
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
            .padding()
            
            // Отображение сырого ответа для отладки
            if !rawResponse.isEmpty {
                ScrollView {
                    Text("Ответ сервера:")
                        .font(.caption)
                    Text(rawResponse)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(height: 100)
                .padding()
            }
            
            // Основное содержимое чата
            if isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack {
                    Text("Ошибка:")
                        .font(.headline)
                    Text(error)
                        .foregroundColor(.red)
                    if let chat = chat {
                        ChatMessagesView(chat: chat)
                    }
                }
            } else if let chat = chat {
                ChatMessagesView(chat: chat)
            } else {
                Text("Чат не найден")
                    .frame(maxHeight: .infinity)
            }
            
            // Поле ввода сообщения
            HStack {
                TextField("Написать сообщение...", text: $newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .background(Color(hex: "#F4F4F4"))
        .navigationBarHidden(true)
        .onAppear {
            fetchOrCreateChat()
        }
    }
    
    private func fetchOrCreateChat() {
        guard authManager.isAuthenticated, let token = authManager.authToken else {
            errorMessage = "Требуется авторизация"
            return
        }
        
        isLoading = true
        errorMessage = nil
        rawResponse = ""
        
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
                
                let responseString = String(data: data, encoding: .utf8) ?? "Не удалось конвертировать данные"
                self.rawResponse = responseString
                print("GET /api/chats response: \(responseString)")
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let chats = try decoder.decode([Chat].self, from: data)
                    completion(chats)
                } catch {
                    self.errorMessage = "Ошибка декодирования: \(error.localizedDescription)\n\nОтвет сервера: \(responseString)"
                }
            }
        }.resume()
    }
    
    private func createChat() {
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
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["propertyId": propertyId]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            errorMessage = "Ошибка создания запроса: \(error.localizedDescription)"
            isLoading = false
            return
        }
        
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
                
                let responseString = String(data: data, encoding: .utf8) ?? "Не удалось конвертировать данные"
                self.rawResponse = responseString
                print("POST /api/chats response: \(responseString)")
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let newChat = try decoder.decode(Chat.self, from: data)
                    self.chat = newChat
                } catch {
                    self.errorMessage = "Ошибка декодирования: \(error.localizedDescription)\n\nОтвет сервера: \(responseString)"
                }
            }
        }.resume()
    }
    
    private func sendMessage() {
        // TODO: Реализация отправки сообщения
        newMessageText = ""
    }
}

struct ChatMessagesView: View {
    let chat: Chat
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if chat.messages.isEmpty {
                    Text("Нет сообщений")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(chat.messages) { message in
                        MessageView(message: message,
                                  isCurrentUser: message.sender.id == authManager.currentUser?.id)
                    }
                }
            }
            .padding()
        }
    }
}

struct MessageView: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(10)
                
                Text(formatDate(message.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "HH:mm, d MMM"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
}
