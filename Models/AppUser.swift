import Foundation

/// Stored in Firestore: /users/{uid}
struct AppUser: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var phone: String
    var neighborhood: String
    var rating: Double
    var ratingCount: Int
    var createdAt: Date
}
