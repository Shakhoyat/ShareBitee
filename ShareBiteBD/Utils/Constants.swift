import SwiftUI

/// Single source of truth for design tokens.
enum Constants {

    // MARK: - Colors (Purple / Lavender design system)
    static let primary       = Color(hex: "7B5EA7")
    static let accent        = Color(hex: "4B3480")
    static let secondary     = Color(hex: "FF9800")
    static let background    = Color(hex: "F5F5F5")
    static let surface       = Color.white
    static let textPrimary   = Color(hex: "1A1A2E")
    static let textSecondary = Color(hex: "6B7280")
    static let success       = Color(hex: "4CAF50")
    static let warning       = Color(hex: "FF9800")
    static let danger        = Color(hex: "E53935")
    static let cream         = Color(hex: "FFF8E1")

    // MARK: - Corner Radii
    enum Corner {
        static let card:   CGFloat = 16
        static let button: CGFloat = 14
        static let chip:   CGFloat = 20
    }

    // MARK: - Padding / Spacing
    enum Spacing {
        static let horizontal: CGFloat = 16
        static let vertical:   CGFloat = 12
        static let card:       CGFloat = 16
        static let section:    CGFloat = 24
    }

    // MARK: - Shadow (card standard)
    enum Shadow {
        static let color:  Color  = .black.opacity(0.06)
        static let radius: CGFloat = 8
        static let y:      CGFloat = 4
    }
}
