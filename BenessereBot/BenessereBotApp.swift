import SwiftUI

@main
struct BenessereBotApp: App {
    @State private var showIntro = !UserDefaults.standard.bool(forKey: "hasSeenIntro")

    var body: some Scene {
        WindowGroup {
            if showIntro {
                IntroView(showIntro: $showIntro)
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}

enum Tab: String, CaseIterable {
    case home = "Home"
    case chat = "Chat"
    case community = "Spazio"
    case profile = "Profilo"

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "message.fill"
        case .community: return "globe"
        case .profile: return "person.crop.circle.fill"
        }
    }
}
