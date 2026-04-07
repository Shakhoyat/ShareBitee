import Foundation
import Combine
import SwiftUI

/// ViewModel for ProfileView and MyPostsView.
/// Fetches the user's own posts from Firestore and supports deletion.
final class ProfileViewModel: ObservableObject {
    @Published var userPosts: [FoodPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchUserPosts(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            userPosts = try await FirestoreService.shared.fetchUserPosts(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePost(at offsets: IndexSet) {
        let postsToDelete = offsets.map { userPosts[$0] }
        userPosts.remove(atOffsets: offsets)
        for post in postsToDelete {
            Task {
                do {
                    try await FirestoreService.shared.deletePost(postId: post.id)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
