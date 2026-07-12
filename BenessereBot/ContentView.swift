import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label(Tab.home.rawValue, systemImage: Tab.home.icon) }
            ChatView().tabItem { Label(Tab.chat.rawValue, systemImage: Tab.chat.icon) }
            WellbeingView().tabItem { Label(Tab.wellbeing.rawValue, systemImage: Tab.wellbeing.icon) }
            ProfileView().tabItem { Label(Tab.profile.rawValue, systemImage: Tab.profile.icon) }
        }
    }
}
