import SwiftUI

/// Root of the unauthenticated flow. Shows LoginView and presents
/// RegisterView as a sheet (native iOS pattern for sign-up).
struct AuthView: View {
    @State private var showRegister = false

    var body: some View {
        LoginView(showRegister: $showRegister)
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
