import Foundation
import FirebaseAuth
import FirebaseFirestore

/// App-wide auth state.
/// Created with @StateObject at root, injected as @EnvironmentObject everywhere.
final class AuthViewModel: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isLoggedIn   = false
    @Published var isLoading    = false
    @Published var errorMessage: String?

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Persist session across launches
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { [weak self] in
                if let firebaseUser {
                    self?.isLoggedIn = true
                    await self?.loadUser(uid: firebaseUser.uid)
                } else {
                    self?.isLoggedIn  = false
                    self?.currentUser = nil
                }
            }
        }
    }

    private func loadUser(uid: String) async {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users").document(uid).getDocument()
            currentUser = try snapshot.data(as: AppUser.self)
        } catch {
            print("[AuthVM] loadUser: \(error.localizedDescription)")
        }
    }

    func register(name: String, email: String, password: String, phone: String) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            let fbUser = try await AuthService.shared.register(email: email, password: password)
            let user = AppUser(id: fbUser.uid,
                               name: name,
                               email: email,
                               phone: phone,
                               neighborhood: "",
                               rating: 0.0,
                               ratingCount: 0,
                               createdAt: Date())
            try await Firestore.firestore()
                .collection("users").document(fbUser.uid).setData(from: user)
            currentUser = user
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
