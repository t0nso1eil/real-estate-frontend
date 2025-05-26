import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @State private var showingBookingRequest = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Заглушка для изображения
                Image("apart1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                VStack(alignment: .leading, spacing: 8) {
                    Text(property.title)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack {
                        Text("\(Int(property.price)) ₽/мес")
                            .font(.title2)
                            .foregroundColor(.blue)

                        Spacer()

                        Text(property.propertyType)
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }

                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(property.location)
                    }
                    .foregroundColor(.secondary)
                }

                Divider()

                Text("Описание")
                    .font(.headline)

                Text(property.description)

                Spacer()

                Button(action: {
                    showingBookingRequest = true
                }) {
                    Text("Создать заявку")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .sheet(isPresented: $showingBookingRequest) {
                    CreateBookingRequestView(property: property)
                }
            }.padding()
        }
        .navigationTitle(property.title)
    }
}
