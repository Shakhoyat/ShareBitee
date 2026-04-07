import Foundation

/// Stored in Firestore: /foodPosts/{postId}/comments/{commentId}
struct Comment: Identifiable, Codable {
    var id: String
    var authorId: String
    var authorName: String
    var text: String
    var createdAt: Date
}
