import SwiftUI

/// Shows time remaining until a post expires.
/// Turns warning-orange when under 30 minutes remain.
struct ExpiryBadge: View {
    let expiresAt: Date

    private var remaining: TimeInterval { expiresAt.timeIntervalSinceNow }
    private var isExpired: Bool  { remaining <= 0 }
    private var isUrgent: Bool   { !isExpired && remaining < 30 * 60 }

    private var badgeColor: Color {
        if isExpired { return .gray }
        return isUrgent ? Constants.warning : Constants.success
    }

    private var label: String {
        if isExpired { return "Expired" }
        let total = Int(remaining)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 { return "\(h)h \(m)m left" }
        return "\(m)m left"
    }

    var body: some View {
        Text(label)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor)
            .clipShape(Capsule())
            .accessibilityValue(label)
    }
}
