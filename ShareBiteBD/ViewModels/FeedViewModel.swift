import Foundation
import Combine

/// ViewModel for HomeFeedView.
/// Owns the list of active posts and handles category filtering + like toggling.
final class FeedViewModel: ObservableObject {
    @Published var posts: [FoodPost] = []
    @Published var selectedCategory: FoodCategory? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Posts filtered by the selected category chip (all posts if nil).
    var filteredPosts: [FoodPost] {
        guard let cat = selectedCategory else { return posts }
        return posts.filter { $0.category == cat }
    }

    // MARK: - Fetch

    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            posts = try await FirestoreService.shared.fetchActivePosts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Like (optimistic update)

    func toggleLike(post: FoodPost, userId: String) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }

        let wasLiked = posts[idx].likedBy.contains(userId)

        // Optimistic local update
        if wasLiked {
            posts[idx].likedBy.removeAll { $0 == userId }
            posts[idx].likesCount = max(0, posts[idx].likesCount - 1)
        } else {
            posts[idx].likedBy.append(userId)
            posts[idx].likesCount += 1
        }

        Task {
            do {
                try await FirestoreService.shared.toggleLike(
                    postId: post.id,
                    userId: userId,
                    isLiked: wasLiked
                )
            } catch {
                // Revert on failure by re-fetching
                await fetchPosts()
            }
        }
    }
}
