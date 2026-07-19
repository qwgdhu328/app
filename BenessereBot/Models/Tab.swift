import SwiftUI

enum Tab: String, CaseIterable {
    case home = "Home"
    case chat = "Chat"
    case wellbeing = "Benessere"
    case profile = "Profilo"

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "message.fill"
        case .wellbeing: return "heart.circle.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}
