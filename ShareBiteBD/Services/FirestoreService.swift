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

    // MARK: - Likes

    func toggleLike(postId: String, userId: String, isLiked: Bool) async throws {
        let ref = db.collection("foodPosts").document(postId)
        if isLiked {
            try await ref.updateData([
                "likedBy": FieldValue.arrayRemove([userId]),
                "likesCount": FieldValue.increment(Int64(-1))
            ])
        } else {
            try await ref.updateData([
                "likedBy": FieldValue.arrayUnion([userId]),
                "likesCount": FieldValue.increment(Int64(1))
            ])
        }
    }

    // MARK: - Reservations

    func reserveServing(postId: String, quantity: Int = 1) async throws -> Int {
        let ref = db.collection("foodPosts").document(postId)

        let doc = try await ref.getDocument()
        guard let currentQty = doc.data()?["availableQuantity"] as? Int,
              currentQty >= quantity else {
            throw NSError(
                domain: "ShareBite",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Not enough servings available"]
            )
        }

        let newQty = currentQty - quantity
        var update: [String: Any] = [
            "availableQuantity": FieldValue.increment(Int64(-quantity))
        ]
        if newQty == 0 {
            update["status"] = PostStatus.fullyClaimed.rawValue
        }
        try await ref.updateData(update)
        return newQty
    }
}
