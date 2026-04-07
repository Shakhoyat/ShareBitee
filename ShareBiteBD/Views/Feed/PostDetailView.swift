import SwiftUI
import Combine

/// Full detail view for a single food post.
/// Displays hero image, metadata, like/reserve actions, and comments.
struct PostDetailView: View {
    @StateObject private var vm: PostDetailViewModel
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    init(post: FoodPost) {
        _vm = StateObject(wrappedValue: PostDetailViewModel(post: post))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage
                contentSection
                commentsSection
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 100) }
        .navigationTitle(vm.post.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                reserveBar
            }
        }
        .alert("Error", isPresented: .init(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .alert("Reserved!", isPresented: $vm.showContactAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Contact \(vm.post.sharerName) at \(vm.post.sharerPhone) to arrange pickup.")
        }
        .task {
            await vm.loadComments()
        }
    }

    // MARK: - Hero image

    private var heroImage: some View {
        Image(vm.post.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .clipped()
            .accessibilityHidden(true)
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(vm.post.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Constants.textPrimary)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                    FoodCategoryChip(category: vm.post.category, isSelected: false, action: {})
                }
                Spacer()
                ExpiryBadge(expiresAt: vm.post.expiresAt)
                    .padding(.top, 4)
            }

            Divider()

            HStack(spacing: 20) {
                Label {
                    Text("\(vm.post.availableQuantity) servings left")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(vm.post.availableQuantity > 0 ? Constants.success : Constants.textSecondary)
                } icon: {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(Constants.primary)
                }
                .accessibilityLabel("\(vm.post.availableQuantity) servings available")

                Spacer()
                likeButton
            }

            Label {
                Text(vm.post.neighborhood)
                    .font(.subheadline)
                    .foregroundStyle(Constants.textSecondary)
            } icon: {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(Constants.primary)
            }

            HStack(spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Constants.primary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Shared by")
                        .font(.caption)
                        .foregroundStyle(Constants.textSecondary)
                    Text(vm.post.sharerName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Constants.textPrimary)
                }
            }

            if !vm.post.description.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("About this food")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Constants.textPrimary)
                    Text(vm.post.description)
                        .font(.body)
                        .foregroundStyle(Constants.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(Constants.Spacing.horizontal)
    }

    // MARK: - Like button

    private var likeButton: some View {
        let userId = auth.currentUser?.id ?? ""
        let isLiked = vm.post.likedBy.contains(userId)

        return Button {
            vm.toggleLike(userId: userId)
        } label: {
            HStack(spacing: 5) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(isLiked ? Constants.primary : Constants.textSecondary)
                    .animation(Constants.Animation.spring, value: isLiked)
                Text("\(vm.post.likesCount)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Constants.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLiked ? "Unlike this post" : "Like this post")
        .accessibilityValue("\(vm.post.likesCount) likes")
    }

    // MARK: - Comments

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .padding(.horizontal, Constants.Spacing.horizontal)

            Text("Comments")
                .font(.headline)
                .foregroundStyle(Constants.textPrimary)
                .padding(.horizontal, Constants.Spacing.horizontal)

            if vm.isLoadingComments {
                ProgressView()
                    .tint(Constants.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if vm.comments.isEmpty {
                Text("No comments yet. Be the first!")
                    .font(.subheadline)
                    .foregroundStyle(Constants.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(vm.comments) { comment in
                        commentRow(comment)
                    }
                }
                .padding(.horizontal, Constants.Spacing.horizontal)
            }

            commentInputBar
                .padding(.horizontal, Constants.Spacing.horizontal)
                .padding(.bottom, 16)
        }
    }

    private func commentRow(_ comment: Comment) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "person.circle.fill")
                .font(.title3)
                .foregroundStyle(Constants.primary.opacity(0.6))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.authorName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Constants.textPrimary)
                    Spacer()
                    Text(comment.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(Constants.textSecondary)
                }
                Text(comment.text)
                    .font(.subheadline)
                    .foregroundStyle(Constants.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var commentInputBar: some View {
        HStack(spacing: 10) {
            TextField("Add a comment…", text: $vm.commentText, axis: .vertical)
                .font(.subheadline)
                .lineLimit(1...4)
                .submitLabel(.send)
                .onSubmit { sendComment() }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .accessibilityLabel("Comment input")

            Button(action: sendComment) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        vm.commentText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Constants.primary.opacity(0.3)
                            : Constants.primary
                    )
            }
            .buttonStyle(.plain)
            .disabled(vm.commentText.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityLabel("Send comment")
        }
    }

    private func sendComment() {
        guard let user = auth.currentUser else { return }
        Task { await vm.addComment(userId: user.id, userName: user.name) }
    }

    // MARK: - Reserve bar

    private var reserveBar: some View {
        let isSoldOut = vm.post.availableQuantity == 0 || vm.post.status == .fullyClaimed

        return VStack(spacing: 0) {
            Divider()
            VStack(spacing: 10) {
                if !isSoldOut {
                    HStack {
                        Text("Quantity:")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Constants.textPrimary)
                        Stepper("\(vm.reserveQuantity)", value: $vm.reserveQuantity, in: 1...vm.post.availableQuantity)
                            .accessibilityLabel("Reserve quantity stepper")
                            .accessibilityValue("\(vm.reserveQuantity) servings")
                    }
                }
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        if isSoldOut {
                            Text("Fully Reserved")
                                .font(.headline)
                                .foregroundStyle(Constants.textSecondary)
                        } else {
                            Text("\(vm.post.availableQuantity) serving\(vm.post.availableQuantity == 1 ? "" : "s")")
                                .font(.headline)
                                .foregroundStyle(Constants.textPrimary)
                            Text("available to reserve")
                                .font(.caption)
                                .foregroundStyle(Constants.textSecondary)
                        }
                    }
                    Spacer()

                    Button {
                        guard let user = auth.currentUser else { return }
                        Task { await vm.reserve(reserverId: user.id, reserverName: user.name) }
                    } label: {
                        Group {
                            if vm.isReserving {
                                ProgressView().tint(.white)
                            } else {
                                Text(isSoldOut ? "Sold Out" : "Reserve \(vm.reserveQuantity)")
                                    .font(.headline)
                            }
                        }
                        .frame(width: 140, height: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(isSoldOut ? Color(.systemGray4) : Constants.primary)
                    .disabled(isSoldOut || vm.isReserving)
                    .accessibilityLabel(isSoldOut ? "Fully reserved" : "Reserve \(vm.reserveQuantity) servings")
                }
            }
            .padding(.horizontal, Constants.Spacing.horizontal)
            .padding(.vertical, 12)
            .background(Constants.surface)
        }
    }
}
