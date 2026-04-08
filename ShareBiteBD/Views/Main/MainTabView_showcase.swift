import SwiftUI
import Combine

/// Phase 1 demo version of MainTabView.
/// Includes: Home feed + Share food sheet.
/// Phase 2 will add: My Posts, Bookings, full Profile tabs.
struct MainTabView: View {
    @StateObject private var feedVM = FeedViewModel()
    @State private var selectedTab = 0
    @State private var showCreatePost = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeFeedView(feedVM: feedVM)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            Color.clear
                .tabItem { Label("Share", systemImage: "plus.circle.fill") }
                .tag(1)

            profilePlaceholder
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(2)
        }
        .tint(Color.appPrimary)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 1 {
                showCreatePost = true
                selectedTab = 0
            }
        }
        .sheet(isPresented: $showCreatePost) {
            ShareFoodView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Profile placeholder (Phase 2)

    private var profilePlaceholder: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Constants.primary.opacity(0.4))
                    .accessibilityHidden(true)
                Text("Profile — Phase 2")
                    .font(.headline)
                    .foregroundStyle(Constants.textPrimary)
                Text("Full profile with My Posts,\nBookings, and Rating coming next week.")
                    .font(.subheadline)
                    .foregroundStyle(Constants.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Constants.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
