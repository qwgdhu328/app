import SwiftUI

@main
struct BenessereBotApp: App {
    @State private var selectedTab: Tab = .home

    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab)
        }
    }
}

enum Tab: String, CaseIterable {
    case home = "Home"
    case chat = "Chat"
    case community = "Spazio"
    case profile = "Tu"

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "message.fill"
        case .community: return "globe"
        case .profile: return "person.crop.circle.fill"
        }
    }
}
