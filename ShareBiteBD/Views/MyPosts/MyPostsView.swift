import SwiftUI
import Combine

/// My Posts tab — shows the current user's food posts with swipe-to-delete.
struct MyPostsView: View {
    @ObservedObject var postsVM: ProfileViewModel
    @EnvironmentObject var auth: AuthViewModel

    @State private var showDeleteAlert = false
    @State private var pendingDeleteOffsets: IndexSet?
    @State private var selectedPost: FoodPost?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            Group {
                if postsVM.isLoading && postsVM.userPosts.isEmpty {
                    ProgressView()
                        .tint(Constants.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if postsVM.userPosts.isEmpty {
                    emptyState
                } else {
                    postsList
                }
            }
            .navigationTitle("My Posts")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showDetail) {
                if let post = selectedPost {
                    PostDetailView(post: post)
                }
            }
            .alert("Delete Post?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let offsets = pendingDeleteOffsets {
                        postsVM.deletePost(at: offsets)
                        pendingDeleteOffsets = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    pendingDeleteOffsets = nil
                }
            } message: {
                Text("This post will be permanently removed.")
            }
            .alert("Error", isPresented: .init(
                get: { postsVM.errorMessage != nil },
                set: { if !$0 { postsVM.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { postsVM.errorMessage = nil }
            } message: {
                Text(postsVM.errorMessage ?? "")
            }
        }
        .task {
            if let userId = auth.currentUser?.id {
                await postsVM.fetchUserPosts(userId: userId)
            }
        }
    }

    // MARK: - Posts List

    private var postsList: some View {
        List {
            ForEach(postsVM.userPosts) { post in
                Button {
                    selectedPost = post
                    showDetail = true
                } label: {
                    postRow(post)
                }
                .buttonStyle(.plain)
            }
            .onDelete { offsets in
                pendingDeleteOffsets = offsets
                showDeleteAlert = true
            }
        }
        .listStyle(.plain)
        .safeBottomPadding()
        .refreshable {
            if let userId = auth.currentUser?.id {
                await postsVM.fetchUserPosts(userId: userId)
            }
        }
    }

    private func postRow(_ post: FoodPost) -> some View {
        HStack(spacing: 12) {
            Image(post.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Constants.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: post.category.sfSymbol)
                        .font(.caption2)
                        .foregroundStyle(Constants.primary)
                    Text(post.category.label)
                        .font(.caption)
                        .foregroundStyle(Constants.textSecondary)

                    Text("·")
                        .foregroundStyle(Constants.textSecondary)

                    Text("\(post.availableQuantity)/\(post.totalQuantity) left")
                        .font(.caption)
                        .foregroundStyle(Constants.textSecondary)
                }
            }

            Spacer()

            statusBadge(post.status)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(post.title), \(post.status.rawValue)")
    }

    /// Ternary-colored status badge: green (available), orange (partial), red (claimed)
    private func statusBadge(_ status: PostStatus) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case .available:        return ("Active", Constants.success)
            case .partiallyClaimed: return ("Partial", Constants.warning)
            case .fullyClaimed:     return ("Claimed", Constants.danger)
            }
        }()

        return Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 56))
                .foregroundStyle(Constants.primary.opacity(0.4))
                .accessibilityHidden(true)
            Text("No posts yet")
                .font(.headline)
                .foregroundStyle(Constants.textPrimary)
            Text("Tap the Share tab to post your first plate!")
                .font(.subheadline)
                .foregroundStyle(Constants.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
