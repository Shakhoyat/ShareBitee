import SwiftUI

extension Color {
    /// Initialise a Color from a 6-digit hex string, e.g. "FF2B85"
    init(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned = String(cleaned.dropFirst()) }
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >>  8) & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - App Palette (use these everywhere)
extension Color {
    static let appPrimary    = Color(hex: "7B5EA7")
    static let appAccent     = Color(hex: "4B3480")
    static let appSecondary  = Color(hex: "FF9800")
    static let appBackground = Color(hex: "F5F5F5")
    static let appTextSec    = Color(hex: "888888")
    static let appSuccess    = Color(hex: "4CAF50")
}
