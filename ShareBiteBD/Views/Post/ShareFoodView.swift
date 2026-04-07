import SwiftUI
import Combine

/// Create-post sheet, accessible via the "+" tab.
/// Uses PostViewModel for form state, MapKit typeahead for location.
struct ShareFoodView: View {
    @StateObject private var postVM = PostViewModel()
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                    categorySection
                }
                .padding(.horizontal, Constants.Spacing.horizontal)
                .padding(.top, Constants.Spacing.vertical)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 20) }
            .background(Constants.background.ignoresSafeArea())
            .navigationTitle("Share Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Constants.primary)
                        .accessibilityLabel("Cancel and go back")
                }
            }
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Food Title *")
            TextField("e.g. Wedding biryani for 20 people", text: $postVM.title)
                .submitLabel(.next)
                .fieldStyle()
                .accessibilityLabel("Food title input")
        }
    }

    // MARK: - Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Category *")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FoodCategory.allCases) { cat in
                        FoodCategoryChip(
                            category: cat,
                            isSelected: postVM.selectedCategory == cat,
                            action: {
                                withAnimation(Constants.Animation.spring) {
                                    postVM.selectedCategory = cat
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Constants.textPrimary)
    }
}

// MARK: - TextField field style extension
private extension View {
    func fieldStyle() -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: Constants.Corner.button))
    }
}
