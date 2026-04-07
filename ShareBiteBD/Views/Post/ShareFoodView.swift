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
                    quantitySection
                    descriptionSection
                    dietarySection
                    locationSection
                    imageSection
                    submitButton
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
            .alert("Error", isPresented: .init(
                get: { postVM.errorMessage != nil },
                set: { if !$0 { postVM.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { postVM.errorMessage = nil }
            } message: {
                Text(postVM.errorMessage ?? "")
            }
            .onChange(of: postVM.didSubmitSuccessfully) { _, success in
                if success { dismiss() }
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

    // MARK: - Image picker

    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Post Image")
            ImagePickerGrid(selectedImageName: $postVM.selectedImageName)
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button {
            Task {
                guard let user = auth.currentUser else { return }
                await postVM.submitPost(
                    sharerId: user.id,
                    sharerName: user.name,
                    sharerPhone: user.phone
                )
            }
        } label: {
            Group {
                if postVM.isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Text("Share Food")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Constants.primary)
        .disabled(!postVM.isFormValid || postVM.isSubmitting)
        .accessibilityLabel("Share food post")
        .padding(.bottom, 24)
    }

    // MARK: - Dietary Tags

    private var dietarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Dietary Tags")
            ForEach(DietaryTag.allCases) { tag in
                Toggle(tag.label, isOn: Binding(
                    get: { postVM.dietaryTags.contains(tag) },
                    set: { isOn in
                        if isOn {
                            postVM.dietaryTags.insert(tag)
                        } else {
                            postVM.dietaryTags.remove(tag)
                        }
                    }
                ))
                .tint(Constants.primary)
                .accessibilityLabel("\(tag.label) dietary tag")
            }
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Pickup Neighborhood *")
            TextField("e.g. Dhanmondi, Gulshan, Mirpur…", text: $postVM.neighborhood)
                .fieldStyle()
                .accessibilityLabel("Neighborhood input")

            sectionLabel("Area (optional)")
            TextField("e.g. Road 27, Block C", text: $postVM.area)
                .fieldStyle()
                .accessibilityLabel("Area input")
        }
    }

    // MARK: - Quantity

    private var quantitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Servings Available *")
            HStack {
                Text("\(postVM.quantity) serving\(postVM.quantity == 1 ? "" : "s")")
                    .font(.body)
                    .foregroundStyle(Constants.textPrimary)
                Spacer()
                Stepper("", value: $postVM.quantity, in: 1...100)
                    .labelsHidden()
                    .accessibilityLabel("Servings stepper")
                    .accessibilityValue("\(postVM.quantity) servings")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: Constants.Corner.button))
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Description")
            TextField("Briefly describe the food, freshness, allergens…",
                      text: $postVM.description)
                .fieldStyle()
                .accessibilityLabel("Description of food")
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
