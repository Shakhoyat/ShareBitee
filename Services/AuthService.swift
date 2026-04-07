import Foundation
import FirebaseAuth

/// Thin wrapper around Firebase Auth — no business logic here.
final class AuthService {
    static let shared = AuthService()
    private init() {}

    func register(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }

    func login(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    var currentFirebaseUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }
}
