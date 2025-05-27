import SwiftUI

struct CreateBookingRequestView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    let property: Property
    
    @State private var requestedStartDate = Date()
    @State private var requestedEndDate = Date().addingTimeInterval(86400)
    @State private var isLoading = false
    @State private var alertItem: AlertItem?
    
    private var bookingService: BookingService {
        BookingService(authManager: authManager)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Даты бронирования")) {
                    DatePicker("Дата заезда",
                              selection: $requestedStartDate,
                              in: Date()...,
                              displayedComponents: .date)
                    
                    DatePicker("Дата выезда",
                              selection: $requestedEndDate,
                              in: requestedStartDate...,
                              displayedComponents: .date)
                }
                
                Section {
                    Button(action: createBookingRequest) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Отправить заявку")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Новая заявка")
            .navigationBarItems(leading: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(item: $alertItem) { item in
                Alert(
                    title: Text(item.title),
                    message: Text(item.message),
                    dismissButton: .default(Text("OK"), action: {
                        if item.shouldDismiss {
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                )
            }
        }
    }
    
    private func createBookingRequest() {
        guard requestedEndDate > requestedStartDate else {
            showAlert(title: "Ошибка", message: "Дата выезда должна быть позже даты заезда", dismiss: false)
            return
        }
        
        guard let tenantId = authManager.currentUser?.id else {
            showAlert(title: "Ошибка", message: "Пользователь не авторизован", dismiss: false)
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let request = BookingRequest(
                    propertyId: property.id,
                    tenantId: tenantId,
                    startDate: requestedStartDate,
                    endDate: requestedEndDate
                )
                
                try await bookingService.createBookingRequest(request)
                showSuccess()
            } catch {
                showError(error)
            }
            
            isLoading = false
        }
    }
    
    private func showSuccess() {
        showAlert(title: "Успешно", message: "Заявка на бронирование создана", dismiss: true)
    }
    
    private func showError(_ error: Error) {
        let message: String
        
        if let propertyError = error as? PropertyError {
            message = propertyError.errorDescription ?? "Неизвестная ошибка"
        } else {
            message = error.localizedDescription
        }
        
        showAlert(title: "Ошибка", message: message, dismiss: false)
    }
    
    private func showAlert(title: String, message: String, dismiss: Bool) {
        alertItem = AlertItem(title: title, message: message, shouldDismiss: dismiss)
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let shouldDismiss: Bool
}
