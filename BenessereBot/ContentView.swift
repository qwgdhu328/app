import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(Tab.home.rawValue, systemImage: Tab.home.icon) {
                HomeView()
            }
            Tab(Tab.chat.rawValue, systemImage: Tab.chat.icon) {
                ChatView()
            }
            Tab(Tab.community.rawValue, systemImage: Tab.community.icon) {
                CommunityView()
            }
            Tab(Tab.profile.rawValue, systemImage: Tab.profile.icon) {
                ProfileView()
            }
        }
        .tabViewStyle(.tabBarOnly)
    }
}
