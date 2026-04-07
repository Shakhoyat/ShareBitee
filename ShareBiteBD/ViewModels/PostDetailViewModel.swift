import Foundation

/// ViewModel for PostDetailView.
/// Owns the mutable local copy of the post, comments list, and social actions.
final class PostDetailViewModel: ObservableObject {

    @Published var post: FoodPost
    @Published var comments: [Comment] = []
    @Published var commentText = ""
    @Published var isLoadingComments = false
    @Published var isReserving = false
    @Published var reserveQuantity = 1
    @Published var errorMessage: String?
    @Published var showContactAlert = false

    init(post: FoodPost) {
        self.post = post
    }

    // MARK: - Comments

    func loadComments() async {
        isLoadingComments = true
        defer { isLoadingComments = false }
        do {
            comments = try await FirestoreService.shared.fetchComments(postId: post.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addComment(userId: String, userName: String) async {
        let text = commentText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        let comment = Comment(
            id: UUID().uuidString,
            authorId: userId,
            authorName: userName,
            text: text,
            createdAt: Date()
        )

        // Optimistic local append
        comments.append(comment)
        commentText = ""

        do {
            try await FirestoreService.shared.addComment(postId: post.id, comment: comment)
        } catch {
            // Revert on failure
            comments.removeAll { $0.id == comment.id }
            commentText = text
            errorMessage = error.localizedDescription
        }
    }
}
