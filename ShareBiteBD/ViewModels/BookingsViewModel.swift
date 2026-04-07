import Foundation
import Combine

/// ViewModel for BookingsView.
/// Fetches the current user's bookings from Firestore.
final class BookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchBookings(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            bookings = try await FirestoreService.shared.fetchBookings(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
