import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(Tab.home)
                ChatView()
                    .tag(Tab.chat)
                CommunityView()
                    .tag(Tab.community)
                ProfileView()
                    .tag(Tab.profile)
            }
            LiquidGlassTabBar(selectedTab: $selectedTab)
                .frame(height: 50)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .ignoresSafeArea(.keyboard)
    }
}
