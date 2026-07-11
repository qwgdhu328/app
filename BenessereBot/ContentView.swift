import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selectedTab {
            case .home:
                HomeView()
            case .chat:
                ChatView()
            case .community:
                CommunityView()
            case .profile:
                ProfileView()
            }
            LiquidGlassTabBar(selectedTab: $selectedTab)
                .frame(height: 50)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .ignoresSafeArea(.keyboard)
    }
}
