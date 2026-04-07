import Foundation

/// Stored in Firestore: /foodPosts/{postId}
struct FoodPost: Identifiable, Codable {
    var id: String
    var sharerId: String
    var sharerName: String
    var sharerPhone: String
    var title: String
    var description: String
    var category: FoodCategory
    var totalQuantity: Int
    var availableQuantity: Int
    var imageName: String
    var neighborhood: String
    var area: String
    var dietaryTags: [String]
    var expiresAt: Date
    var status: PostStatus
    var createdAt: Date
    var likesCount: Int
    var likedBy: [String]
}
