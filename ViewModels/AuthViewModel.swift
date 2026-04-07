import Foundation
import FirebaseAuth

/// App-wide auth state.
/// Created with @StateObject at root, injected as @EnvironmentObject everywhere.
final class AuthViewModel: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isLoggedIn   = false
    @Published var isLoading    = false
    @Published var errorMessage: String?

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { [weak self] in
                if firebaseUser != nil {
                    self?.isLoggedIn = true
                } else {
                    self?.isLoggedIn  = false
                    self?.currentUser = nil
                }
            }
        }
    }
}
