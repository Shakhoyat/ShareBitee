import Foundation
import FirebaseFirestore

/// Stateless wrapper around all Firestore CRUD operations.
final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()
}
