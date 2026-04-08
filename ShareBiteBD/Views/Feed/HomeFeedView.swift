import SwiftUI
import Combine

struct HomeFeedView: View {
    @ObservedObject var feedVM: FeedViewModel
    @EnvironmentObject var auth: AuthViewModel
    @State private var searchText = ""

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var displayedPosts: [FoodPost] {
        let filtered = feedVM.filteredPosts
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return filtered
        }
        let query = searchText.lowercased()
        return filtered.filter {
            $0.title.lowercased().contains(query) ||
            $0.neighborhood.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if feedVM.isLoading && feedVM.posts.isEmpty {
                    loadingView
                } else if displayedPosts.isEmpty {
                    emptyStateView
                } else {
                    feedScrollView
                }
            }
            .navigationTitle("ShareBite BD")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search food or neighbourhood…")
            .toolbar { toolbarContent }
            .alert("Error", isPresented: .init(
                get: { feedVM.errorMessage != nil },
                set: { if !$0 { feedVM.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { feedVM.errorMessage = nil }
            } message: {
                Text(feedVM.errorMessage ?? "")
            }
        }
        .task {
            await feedVM.fetchPosts()
        }
    }

    // MARK: - Feed scroll (2-col grid)

    private var feedScrollView: some View {
        ScrollView {
            VStack(spacing: 12) {
                categoryChips
                    .padding(.horizontal, Constants.Spacing.horizontal)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(displayedPosts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            FoodPostCard(
                                post: post,
                                currentUserId: auth.currentUser?.id ?? "",
                                onLike: { feedVM.toggleLike(post: post, userId: auth.currentUser?.id ?? "") }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Constants.Spacing.horizontal)
            }
            .padding(.vertical, 12)
        }
        .safeBottomPadding()
        .refreshable {
            await feedVM.fetchPosts()
        }
    }

    // MARK: - Category chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    withAnimation(Constants.Animation.spring) {
                        feedVM.selectedCategory = nil
                    }
                } label: {
                    Text("All")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(feedVM.selectedCategory == nil ? Constants.primary : Color(.systemGray6))
                        .foregroundStyle(feedVM.selectedCategory == nil ? .white : Constants.textPrimary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("All categories")
                .accessibilityAddTraits(.isButton)

                ForEach(FoodCategory.allCases) { cat in
                    FoodCategoryChip(
                        category: cat,
                        isSelected: feedVM.selectedCategory == cat,
                        action: {
                            withAnimation(Constants.Animation.spring) {
                                feedVM.selectedCategory = feedVM.selectedCategory == cat ? nil : cat
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Constants.primary)
                .scaleEffect(1.4)
            Text("Loading posts…")
                .font(.subheadline)
                .foregroundStyle(Constants.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty state

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            categoryChips
                .padding(.horizontal, Constants.Spacing.horizontal)

            Spacer()

            Image(systemName: "fork.knife.circle")
                .font(.system(size: 72))
                .foregroundStyle(Constants.primary.opacity(0.4))

            VStack(spacing: 6) {
                Text("No food posts yet")
                    .font(.headline)
                    .foregroundStyle(Constants.textPrimary)
                Text("Be the first to share a plate\nin your neighbourhood!")
                    .font(.subheadline)
                    .foregroundStyle(Constants.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .refreshable {
            await feedVM.fetchPosts()
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if feedVM.isLoading {
                ProgressView().tint(Constants.primary)
            }
        }
    }
}
