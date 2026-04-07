import Foundation

/// Stored in Firestore: /bookings/{bookingId}
struct Booking: Identifiable, Codable {
    var id: String
    var postId: String
    var foodTitle: String
    var posterUid: String
    var posterName: String
    var reserverId: String
    var reserverName: String
    var quantity: Int
    var status: BookingStatus
    var createdAt: Date
}
