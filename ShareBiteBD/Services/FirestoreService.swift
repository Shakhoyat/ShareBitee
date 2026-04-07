import Foundation
import FirebaseFirestore

/// Stateless wrapper around all Firestore CRUD operations.
final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - Posts

    func createPost(_ post: FoodPost) async throws {
        try db.collection("foodPosts").document(post.id).setData(from: post)
    }

    func fetchActivePosts() async throws -> [FoodPost] {
        let snapshot = try await db.collection("foodPosts")
            .whereField("status", isEqualTo: PostStatus.available.rawValue)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        let now = Date()
        return snapshot.documents
            .compactMap { try? $0.data(as: FoodPost.self) }
            .filter { $0.expiresAt > now && $0.availableQuantity > 0 }
    }

    func fetchUserPosts(userId: String) async throws -> [FoodPost] {
        let snapshot = try await db.collection("foodPosts")
            .whereField("sharerId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: FoodPost.self) }
    }

    func deletePost(postId: String) async throws {
        try await db.collection("foodPosts").document(postId).delete()
    }
}
