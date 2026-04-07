import SwiftUI
import Combine

/// Profile tab — shows user info, their posts, and logout.
struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @ObservedObject var postsVM: ProfileViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    avatarSection
                    if let user = auth.currentUser {
                        infoSection(user: user)
                        ratingSection(user: user)
                    }
                    myPostsSection
                    logoutButton
                }
                .padding(.horizontal, Constants.Spacing.horizontal)
                .padding(.top, 24)
            }
            .safeBottomPadding()
            .background(Constants.background.ignoresSafeArea())
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.large)
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

    // MARK: - Avatar

    private var avatarSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Constants.primary)
                .accessibilityHidden(true)

            if let user = auth.currentUser {
                Text(user.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Constants.textPrimary)
            }
        }
    }

    // MARK: - Info card

    private func infoSection(user: AppUser) -> some View {
        VStack(spacing: 0) {
            infoRow(icon: "envelope.fill", label: "Email", value: user.email)
            Divider().padding(.leading, 50)
            infoRow(
                icon: "phone.fill",
                label: "Phone",
                value: user.phone.isEmpty ? "Not set" : user.phone
            )
            Divider().padding(.leading, 50)
            infoRow(
                icon: "calendar",
                label: "Member since",
                value: user.createdAt.formatted(.dateTime.month(.wide).year())
            )
        }
        .background(Constants.surface)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Corner.card))
        .shadow(color: Constants.Shadow.color, radius: Constants.Shadow.radius, y: Constants.Shadow.y)
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Constants.primary)
                .frame(width: 22)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Constants.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Constants.textPrimary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Rating

    /// Star-row with ternary color: green ≥ 4, orange ≥ 3, red < 3
    private func ratingSection(user: AppUser) -> some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= Int(user.rating.rounded()) ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(
                        user.rating >= 4.0
                            ? Constants.success
                            : user.rating >= 3.0
                                ? Constants.warning
                                : Constants.danger
                    )
                    .accessibilityHidden(true)
            }
            Text(String(format: "%.1f", user.rating))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Constants.textPrimary)
            Text("(\(user.ratingCount))")
                .font(.caption)
                .foregroundStyle(Constants.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating: \(String(format: "%.1f", user.rating)) out of 5, \(user.ratingCount) reviews")
    }

    // MARK: - My Posts

    private var myPostsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Posts")
                    .font(.headline)
                    .foregroundStyle(Constants.textPrimary)
                Spacer()
                if postsVM.isLoading {
                    ProgressView().tint(Constants.primary)
                } else {
                    Text("\(postsVM.userPosts.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Constants.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Constants.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            if postsVM.isLoading {
                ProgressView()
                    .tint(Constants.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if postsVM.userPosts.isEmpty {
                emptyPosts
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(postsVM.userPosts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            postMiniCard(post)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyPosts: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(Constants.primary.opacity(0.4))
                .accessibilityHidden(true)
            Text("No posts yet")
                .font(.subheadline)
                .foregroundStyle(Constants.textSecondary)
            Text("Tap + to share your first plate!")
                .font(.caption)
                .foregroundStyle(Constants.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    private func postMiniCard(_ post: FoodPost) -> some View {
        HStack(spacing: 12) {
            Image(post.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Constants.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    FoodCategoryChip(category: post.category, isSelected: false, action: {})
                }
                HStack(spacing: 4) {
                    Image(systemName: post.status == .available ? "circle.fill" : "circle.slash")
                        .font(.caption2)
                        .foregroundStyle(post.status == .available ? Constants.success : Constants.textSecondary)
                    Text(post.status == .available ? "Active · \(post.availableQuantity) left" : "Claimed")
                        .font(.caption)
                        .foregroundStyle(post.status == .available ? Constants.success : Constants.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Constants.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(12)
        .background(Constants.surface)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Corner.card))
        .shadow(color: Constants.Shadow.color, radius: Constants.Shadow.radius, y: Constants.Shadow.y)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(post.title), \(post.status == .available ? "active, \(post.availableQuantity) servings left" : "claimed")")
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            auth.logout()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .accessibilityHidden(true)
                Text("Log Out")
            }
            .font(.headline)
            .foregroundStyle(Constants.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Constants.primary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: Constants.Corner.button))
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)
        .accessibilityLabel("Log out of your account")
    }
}
