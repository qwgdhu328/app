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
            WellbeingView()
                .tag(Tab.wellbeing)
                .tabItem { Label(Tab.wellbeing.rawValue, systemImage: Tab.wellbeing.icon) }
            ProfileView()
                .tag(Tab.profile)
                .tabItem { Label(Tab.profile.rawValue, systemImage: Tab.profile.icon) }
        }
        .tabViewStyle(.tabBarOnly)
    }
}
