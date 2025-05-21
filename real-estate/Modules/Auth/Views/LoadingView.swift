import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text("Загрузка...")
                .font(.headline)
                .padding(.top, 16)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
