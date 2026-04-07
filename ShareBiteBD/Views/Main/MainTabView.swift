import SwiftUI
import Combine

struct MainTabView: View {
    @StateObject private var feedVM = FeedViewModel()
    @StateObject private var postsVM = ProfileViewModel()
    @State private var selectedTab = 0
    @State private var showCreatePost = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeFeedView(feedVM: feedVM)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            MyPostsView(postsVM: postsVM)
                .tabItem { Label("My Posts", systemImage: "tray.full.fill") }
                .tag(1)

            Color.clear
                .tabItem { Label("Share", systemImage: "plus.circle.fill") }
                .tag(2)

            BookingsView()
                .tabItem { Label("Bookings", systemImage: "list.clipboard.fill") }
                .tag(3)

            ProfileView(postsVM: postsVM)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
        .tint(Color.appPrimary)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 2 {
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
}
