import Foundation

/// ViewModel for ShareFoodView.
/// Owns form state and post submission. No MapKit — uses simple text fields.
final class PostViewModel: ObservableObject {

    // MARK: - Form fields
    @Published var title = ""
    @Published var selectedCategory: FoodCategory = .rice
    @Published var quantity = 1
    @Published var description = ""
    @Published var selectedImageName = "food_biryani"
    @Published var neighborhood = ""
    @Published var area = ""
    @Published var dietaryTags: Set<DietaryTag> = [.halal]

    // MARK: - Submission state
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var didSubmitSuccessfully = false

    // MARK: - Validation

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !neighborhood.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
