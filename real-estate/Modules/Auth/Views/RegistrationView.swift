import SwiftUI

struct RegistrationView: View {
    let role: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var birthDate: String = ""
    @State private var password: String = ""
    @State private var agreedToTerms: Bool = false
    
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var isSuccess = false
    @State private var fieldErrors: [String: String] = [:]
    @State private var navigateToProfile = false
    @State private var serverError: String? = nil
    
    init(role: String) {
        self.role = role
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.957, green: 0.957, blue: 0.957)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(Color(red: 0, green: 0.34, blue: 0.72))
                                    .padding(.leading, 16)
                                    .padding(.top, 16)
                            }
                            Spacer()
                        }
                        
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
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                        
                        Text("Создать аккаунт")
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.top, 24)
                        
                        if let serverError = serverError {
                            Text(serverError)
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 8)
                        }
                        
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                CustomTextField(
                                    title: "Имя",
                                    placeholder: "",
                                    text: $firstName,
                                    errorMessage: fieldErrors["firstName"]
                                )
                                
                                CustomTextField(
                                    title: "Фамилия",
                                    placeholder: "",
                                    text: $lastName,
                                    errorMessage: fieldErrors["lastName"]
                                )
                            }
                            .padding(.top, 32)
                            
                            CustomTextField(
                                title: "Email",
                                placeholder: "",
                                text: $email,
                                errorMessage: fieldErrors["email"]
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            
                            CustomTextField(
                                title: "Номер телефона",
                                placeholder: "",
                                text: $phoneNumber,
                                errorMessage: fieldErrors["phoneNumber"]
                            )
                            .keyboardType(.phonePad)
                            
                            CustomTextField(
                                title: "Дата рождения",
                                placeholder: "ДД.ММ.ГГГГ",
                                text: $birthDate,
                                errorMessage: fieldErrors["birthDate"]
                            )
                            
                            CustomTextField(
                                title: "Пароль",
                                placeholder: "",
                                text: $password,
                                isSecure: true,
                                errorMessage: fieldErrors["password"]
                            )
                        }
                        .padding(.horizontal, 16)
                        
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
                        
                        Button(action: registerUser) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Далее")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(isLoading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 0, green: 0.34, blue: 0.72))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        
                        NavigationLink(destination: LoginView()) {
                            Text("Уже есть аккаунт? Войти здесь")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 32)
                        
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
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if isSuccess {
                            navigateToProfile = true
                        }
                    }
                )
            }
            .background(
                NavigationLink(
                    destination: ProfileView(),
                    isActive: $navigateToProfile,
                    label: { EmptyView() }
                )
            )
        }
        .navigationViewStyle(.stack)
    }
    
    private func registerUser() {
        guard validateForm() else { return }
        
        isLoading = true
        fieldErrors = [:]
        serverError = nil
        
        // Форматирование даты в ISO8601 (YYYY-MM-DD)
        let isoDateFormatter = DateFormatter()
        isoDateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedBirthDate: String
        
        if let date = DateFormatter.birthDateFormatter.date(from: birthDate) {
            formattedBirthDate = isoDateFormatter.string(from: date)
        } else {
            showAlert(title: "Ошибка", message: "Неверный формат даты рождения", isSuccess: false)
            isLoading = false
            return
        }
        
        let registerData: [String: Any] = [
            "firstName": firstName.trimmingCharacters(in: .whitespaces),
            "lastName": lastName.trimmingCharacters(in: .whitespaces),
            "email": email.trimmingCharacters(in: .whitespaces).lowercased(),
            "phone": phoneNumber.trimmingCharacters(in: .whitespaces),
            "birthDate": formattedBirthDate,
            "password": password,
            "role": role.lowercased()
        ]
        
        guard let url = URL(string: "http://localhost:3000/api/users/register") else {
            showAlert(title: "Ошибка", message: "Неверный URL сервера", isSuccess: false)
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: registerData, options: [])
            print("Request body:", String(data: request.httpBody!, encoding: .utf8) ?? "nil")
        } catch {
            showAlert(title: "Ошибка", message: "Ошибка формирования данных: \(error.localizedDescription)", isSuccess: false)
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    serverError = "Ошибка сети: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    serverError = "Неверный ответ сервера"
                    return
                }
                
                print("Status code:", httpResponse.statusCode)
                
                guard let data = data else {
                    serverError = "Пустой ответ от сервера"
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response:", responseString)
                }
                
                if httpResponse.statusCode == 201 {
                    // Успешная регистрация
                    self.handleSuccessfulRegistration(data: data)
                } else {
                    // Ошибка
                    self.handleErrorResponse(data: data, statusCode: httpResponse.statusCode)
                }
            }
        }.resume()
    }

    private func handleSuccessfulRegistration(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Registration success:", json)
                
                self.loginAfterRegistration()
            }
        } catch {
            print("Error parsing success response:", error)
            showAlert(title: "Успешно", message: "Регистрация завершена!", isSuccess: true)
        }
    }

    private func loginAfterRegistration() {
        let loginData: [String: Any] = [
            "email": email.trimmingCharacters(in: .whitespaces).lowercased(),
            "password": password
        ]
        
        guard let url = URL(string: "http://localhost:3000/api/users/login") else {
            showAlert(title: "Успешно", message: "Регистрация завершена! Пожалуйста, войдите.", isSuccess: true)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData, options: [])
        } catch {
            showAlert(title: "Успешно", message: "Регистрация завершена! Пожалуйста, войдите.", isSuccess: true)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                   let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    
                    // Сохраняем токен (например, в Keychain или UserDefaults)
                    UserDefaults.standard.set(token, forKey: "authToken")
                    
                    // Переходим в профиль
                    self.showAlert(title: "Успешно", message: "Добро пожаловать!", isSuccess: true)
                } else {
                    self.showAlert(title: "Успешно", message: "Регистрация завершена! Пожалуйста, войдите.", isSuccess: true)
                }
            }
        }.resume()
    }

    private func handleErrorResponse(data: Data, statusCode: Int) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Error response:", json)
                
                if let errors = json["errors"] as? [[String: String]] {
                    var errorDict = [String: String]()
                    for error in errors {
                        if let field = error["param"], let msg = error["msg"] {
                            errorDict[field] = msg
                        }
                    }
                    fieldErrors = errorDict
                    
                    if errorDict.isEmpty, let message = json["message"] as? String {
                        serverError = message
                    }
                } else if let errorMessage = json["error"] as? String {
                    serverError = errorMessage
                } else {
                    serverError = "Ошибка сервера (код \(statusCode))"
                }
            }
        } catch {
            print("Error parsing error response:", error)
            serverError = "Неизвестная ошибка сервера (код \(statusCode))"
        }
    }
    
    private func validateForm() -> Bool {
        var isValid = true
        var errors = [String: String]()
        
        if firstName.isEmpty {
            errors["firstName"] = "Имя обязательно"
            isValid = false
        } else if firstName.count < 2 {
            errors["firstName"] = "Имя должно содержать минимум 2 символа"
            isValid = false
        }
        
        if lastName.isEmpty {
            errors["lastName"] = "Фамилия обязательна"
            isValid = false
        } else if lastName.count < 2 {
            errors["lastName"] = "Фамилия должна содержать минимум 2 символа"
            isValid = false
        }
        
        if email.isEmpty {
            errors["email"] = "Email обязателен"
            isValid = false
        } else if !email.isValidEmail {
            errors["email"] = "Некорректный email"
            isValid = false
        }
        
        if password.isEmpty {
            errors["password"] = "Пароль обязателен"
            isValid = false
        } else if password.count < 8 {
            errors["password"] = "Пароль должен содержать минимум 8 символов"
            isValid = false
        }
        
        if !agreedToTerms {
            showAlert(title: "Ошибка", message: "Необходимо согласиться с условиями", isSuccess: false)
            return false
        }
        
        fieldErrors = errors
        return isValid
    }
    
    private func showAlert(title: String, message: String, isSuccess: Bool) {
        alertTitle = title
        alertMessage = message
        self.isSuccess = isSuccess
        showAlert = true
    }
}

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}

extension DateFormatter {
    static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(role: "tenant")
    }
}
