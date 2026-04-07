import SwiftUI

// MARK: - FoodCategory (BD food context)
enum FoodCategory: String, Codable, CaseIterable, Identifiable {
    case rice, biryani, dal, roti, halim, iftarItems, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .rice:       return "Rice"
        case .biryani:    return "Biryani"
        case .dal:        return "Dal"
        case .roti:       return "Roti"
        case .halim:      return "Halim"
        case .iftarItems: return "Iftar Items"
        case .other:      return "Other"
        }
    }

    /// SF Symbol name for category icon (no emojis).
    var sfSymbol: String {
        switch self {
        case .rice:       return "fork.knife"
        case .biryani:    return "flame.fill"
        case .dal:        return "cup.and.saucer.fill"
        case .roti:       return "circle.grid.2x2.fill"
        case .halim:      return "leaf.fill"
        case .iftarItems: return "moon.stars.fill"
        case .other:      return "takeoutbag.and.cup.and.straw.fill"
        }
    }

    var color: Color {
        switch self {
        case .rice:       return Color(hex: "7B5EA7")
        case .biryani:    return Color(hex: "E53935")
        case .dal:        return Color(hex: "FF9800")
        case .roti:       return Color(hex: "5D4037")
        case .halim:      return Color(hex: "4CAF50")
        case .iftarItems: return Color(hex: "4B3480")
        case .other:      return Color(hex: "6B7280")
        }
    }
}

// MARK: - DietaryTag
enum DietaryTag: String, Codable, CaseIterable, Identifiable {
    case halal, vegetarian, vegan, nutFree, glutenFree

    var id: String { rawValue }

    var label: String {
        switch self {
        case .halal:      return "Halal"
        case .vegetarian: return "Vegetarian"
        case .vegan:      return "Vegan"
        case .nutFree:    return "Nut-Free"
        case .glutenFree: return "Gluten-Free"
        }
    }
}

// MARK: - PostStatus
enum PostStatus: String, Codable {
    case available
    case partiallyClaimed = "partially_claimed"
    case fullyClaimed     = "fully_claimed"
}

// MARK: - BookingStatus
enum BookingStatus: String, Codable {
    case pending, confirmed, completed, cancelled
}
