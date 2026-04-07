import SwiftUI

/// Pill-shaped category filter button used in the horizontal scroll of HomeFeedView.
struct FoodCategoryChip: View {
    let category: FoodCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.sfSymbol)
                    .font(.subheadline)
                Text(category.label)
                    .font(.subheadline.weight(.medium))
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Constants.primary : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : Constants.textPrimary)
            .clipShape(Capsule())
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category.label) category filter")
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
