import Foundation

final class AuthViewModel: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
}
