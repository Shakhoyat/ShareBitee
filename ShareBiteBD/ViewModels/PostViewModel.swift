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

    // MARK: - Submit

    func submitPost(sharerId: String, sharerName: String, sharerPhone: String) async {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields."
            return
        }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let now = Date()
        let post = FoodPost(
            id: UUID().uuidString,
            sharerId: sharerId,
            sharerName: sharerName,
            sharerPhone: sharerPhone,
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            totalQuantity: quantity,
            availableQuantity: quantity,
            imageName: selectedImageName,
            neighborhood: neighborhood.trimmingCharacters(in: .whitespaces),
            area: area.trimmingCharacters(in: .whitespaces),
            dietaryTags: dietaryTags.map { $0.rawValue },
            expiresAt: now.addingTimeInterval(3 * 3600),
            status: .available,
            createdAt: now,
            likesCount: 0,
            likedBy: []
        )

        do {
            try await FirestoreService.shared.createPost(post)
            didSubmitSuccessfully = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
