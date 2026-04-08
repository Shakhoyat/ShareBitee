import SwiftUI

/// Renders a single food post as a rounded card.
/// Used in HomeFeedView inside a NavigationLink.
struct FoodPostCard: View {
    let post: FoodPost
    let currentUserId: String
    let onLike: () -> Void

    private var isLiked: Bool {
        post.likedBy.contains(currentUserId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            contentSection
        }
        .background(Constants.surface)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Corner.card))
        .shadow(
            color: Constants.Shadow.color,
            radius: Constants.Shadow.radius,
            y: Constants.Shadow.y
        )
    }

    // MARK: - Image

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            Image(post.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipped()
                .accessibilityHidden(true)

            ExpiryBadge(expiresAt: post.expiresAt)
                .padding(10)
        }
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                FoodCategoryChip(category: post.category, isSelected: false, action: {})
                Spacer()
                quantityBadge
            }

            Text(post.title)
                .font(.headline)
                .foregroundStyle(Constants.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Constants.secondary)
                Text(post.neighborhood)
                    .font(.caption)
                    .foregroundStyle(Constants.textSecondary)
                    .lineLimit(1)
                Spacer()
                likeButton
            }
        }
        .padding(Constants.Spacing.card)
    }

    // MARK: - Sub-components

    private var quantityBadge: some View {
        let color = post.availableQuantity == 0 ? Color.gray : Constants.success
        return Text("\(post.availableQuantity) left")
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private var likeButton: some View {
        Button(action: onLike) {
            HStack(spacing: 3) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.subheadline)
                    .foregroundStyle(isLiked ? Constants.primary : Constants.textSecondary)
                Text("\(post.likesCount)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Constants.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLiked ? "Unlike this post" : "Like this post")
        .accessibilityValue("\(post.likesCount) likes")
    }
}
