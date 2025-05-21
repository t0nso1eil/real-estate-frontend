import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Поиск по названию, адресу, описанию", text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(
                                minWidth: 0, maxWidth: .infinity,
                                alignment: .leading
                            )
                            .padding(.leading, 8)

                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
    }
}
