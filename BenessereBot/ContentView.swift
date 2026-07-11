import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .tabItem { Label(Tab.home.rawValue, systemImage: Tab.home.icon) }
            ChatView()
                .tag(Tab.chat)
                .tabItem { Label(Tab.chat.rawValue, systemImage: Tab.chat.icon) }
            CommunityView()
                .tag(Tab.community)
                .tabItem { Label(Tab.community.rawValue, systemImage: Tab.community.icon) }
            ProfileView()
                .tag(Tab.profile)
                .tabItem { Label(Tab.profile.rawValue, systemImage: Tab.profile.icon) }
        }
        .tabViewStyle(.tabBarOnly)
    }
}
