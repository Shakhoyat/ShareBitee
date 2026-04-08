import SwiftUI
import Combine

/// Bookings tab — shows the user's reserved food pickups.
struct BookingsView: View {
    @StateObject private var vm = BookingsViewModel()
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.bookings.isEmpty {
                    ProgressView()
                        .tint(Constants.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.bookings.isEmpty {
                    emptyState
                } else {
                    bookingsList
                }
            }
            .navigationTitle("My Bookings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: .init(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
        .task {
            if let userId = auth.currentUser?.id {
                await vm.fetchBookings(userId: userId)
            }
        }
    }

    // MARK: - List

    private var bookingsList: some View {
        List(vm.bookings) { booking in
            bookingRow(booking)
        }
        .listStyle(.plain)
        .safeBottomPadding()
        .refreshable {
            if let userId = auth.currentUser?.id {
                await vm.fetchBookings(userId: userId)
            }
        }
    }

    private func bookingRow(_ booking: Booking) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bag.fill")
                .font(.title2)
                .foregroundStyle(Constants.primary)
                .frame(width: 44, height: 44)
                .background(Constants.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(booking.foodTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Constants.textPrimary)
                    .lineLimit(1)

                Text("Qty: \(booking.quantity) · \(booking.posterName)")
                    .font(.caption)
                    .foregroundStyle(Constants.textSecondary)

                Text(booking.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(Constants.textSecondary)
            }

            Spacer()

            statusBadge(booking.status)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(booking.foodTitle), quantity \(booking.quantity), status \(booking.status.rawValue)")
    }

    private func statusBadge(_ status: BookingStatus) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case .pending:   return ("Pending", Constants.warning)
            case .confirmed: return ("Confirmed", Constants.primary)
            case .completed: return ("Picked Up", Constants.success)
            case .cancelled: return ("Cancelled", Constants.textSecondary)
            }
        }()

        return Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 56))
                .foregroundStyle(Constants.primary.opacity(0.4))
                .accessibilityHidden(true)

            Text("No bookings yet")
                .font(.headline)
                .foregroundStyle(Constants.textPrimary)

            Text("When you reserve food from a post,\nyour bookings will appear here.")
                .font(.subheadline)
                .foregroundStyle(Constants.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
