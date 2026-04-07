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

    // MARK: - Likes (optimistic)

    func toggleLike(userId: String) {
        let wasLiked = post.likedBy.contains(userId)
        if wasLiked {
            post.likedBy.removeAll { $0 == userId }
            post.likesCount = max(0, post.likesCount - 1)
        } else {
            post.likedBy.append(userId)
            post.likesCount += 1
        }
        Task {
            do {
                try await FirestoreService.shared.toggleLike(postId: post.id, userId: userId, isLiked: wasLiked)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Reserve

    func reserve(reserverId: String, reserverName: String) async {
        let qty = reserveQuantity
        guard qty > 0, qty <= post.availableQuantity else { return }
        isReserving = true
        defer { isReserving = false }
        do {
            let newQty = try await FirestoreService.shared.reserveServing(postId: post.id, quantity: qty)
            post.availableQuantity = newQty
            if newQty == 0 { post.status = .fullyClaimed }

            // Create a Booking document so the reservation appears in BookingsView.
            let booking = Booking(
                id: UUID().uuidString,
                postId: post.id,
                foodTitle: post.title,
                posterUid: post.sharerId,
                posterName: post.sharerName,
                reserverId: reserverId,
                reserverName: reserverName,
                quantity: qty,
                status: .confirmed,
                createdAt: Date()
            )
            try await FirestoreService.shared.createBooking(booking)

            reserveQuantity = 1
            showContactAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
