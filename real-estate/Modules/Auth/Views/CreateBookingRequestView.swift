import SwiftUI

struct CreateBookingRequestView: View {
    @Environment(\.presentationMode) var presentationMode
    let property: Property
    
    // Состояние формы
    @State private var requestedStartDate = Date()
    @State private var requestedEndDate = Date().addingTimeInterval(86400) // +1 день
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var shouldDismiss = false
    
    private let bookingService = BookingService()
    
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if shouldDismiss {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
    
    private func createBookingRequest() {
        guard requestedEndDate > requestedStartDate else {
            showAlert(title: "Ошибка", message: "Дата выезда должна быть позже даты заезда")
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let tenantId = 14
                let request = BookingRequest(
                    propertyId: property.id,
                    tenantId: tenantId,
                    requestedStartDate: requestedStartDate,
                    requestedEndDate: requestedEndDate
                )
                print(request)
                
                try await bookingService.createBookingRequest(request)
                
                showSuccess()
            } catch {
                showError(error)
            }
            
            isLoading = false
        }
    }
    
    private func showSuccess() {
        alertTitle = "Успешно"
        alertMessage = "Заявка на бронирование создана"
        shouldDismiss = true
        showAlert = true
    }
    
    private func showError(_ error: Error) {
        alertTitle = "Ошибка"
        alertMessage = error.localizedDescription
        shouldDismiss = false
        showAlert = true
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        shouldDismiss = false
        showAlert = true
    }
}
