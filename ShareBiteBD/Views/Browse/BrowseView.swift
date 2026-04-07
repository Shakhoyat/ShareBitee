import SwiftUI
import Combine

/// Browse tab — category-based browsing with a grid layout.
struct BrowseView: View {
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
            ScrollView {
                VStack(spacing: 12) {
                    searchBar
                        .padding(.horizontal, Constants.Spacing.horizontal)

                    categoryGrid
                        .padding(.horizontal, Constants.Spacing.horizontal)

                    if feedVM.isLoading && feedVM.posts.isEmpty {
                        ProgressView()
                            .tint(Constants.primary)
                            .padding(.top, 40)
                    } else if displayedPosts.isEmpty {
                        emptyState
                    } else {
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
                }
                .padding(.vertical, 12)
            }
            .safeBottomPadding()
            .navigationTitle("Browse")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await feedVM.fetchPosts()
            }
        }
        .task {
            await feedVM.fetchPosts()
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Constants.textSecondary)
            TextField("Search food or neighborhood…", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Search food posts")
        }
    }

    // MARK: - Category grid

    private var categoryGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    withAnimation { feedVM.selectedCategory = nil }
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

                ForEach(FoodCategory.allCases) { cat in
                    FoodCategoryChip(
                        category: cat,
                        isSelected: feedVM.selectedCategory == cat,
                        action: {
                            withAnimation {
                                feedVM.selectedCategory = feedVM.selectedCategory == cat ? nil : cat
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(Constants.primary.opacity(0.4))
            Text("No matching posts")
                .font(.headline)
                .foregroundStyle(Constants.textPrimary)
            Text("Try a different category or search term")
                .font(.subheadline)
                .foregroundStyle(Constants.textSecondary)
        }
        .padding(.top, 60)
    }
}
