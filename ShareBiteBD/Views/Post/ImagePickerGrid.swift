import SwiftUI

/// A 3-column grid of pre-loaded asset images for the user to pick a post photo.
/// Selecting an image adds a pink border ring and a checkmark.
struct ImagePickerGrid: View {
    @Binding var selectedImageName: String

    private let imageNames = [
        "food_biryani", "food_rice", "food_curry",
        "food_snacks", "food_sweets", "food_mixed"
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(imageNames, id: \.self) { name in
                imageCell(name: name)
            }
        }
    }

    private func imageCell(name: String) -> some View {
        let isSelected = selectedImageName == name
        return Button {
            withAnimation(Constants.Animation.spring) {
                selectedImageName = name
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(name)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isSelected ? Constants.primary : Color.clear,
                                lineWidth: 3
                            )
                    )
                    .accessibilityHidden(true)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, Constants.primary)
                        .padding(5)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Select \(name.replacingOccurrences(of: "food_", with: "")) image")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
