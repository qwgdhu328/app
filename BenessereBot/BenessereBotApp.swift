import SwiftUI

@main
struct BenessereBotApp: App {
    @State private var showIntro = !UserDefaults.standard.bool(forKey: "hasSeenIntro")
    @StateObject private var breathingService = BreathingService()

    init() {
        requestNotificationPermission()
    }

    private func requestNotificationPermission() {
        Task {
            try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppBackground()
                if showIntro {
                    IntroView(showIntro: $showIntro)
                        .transition(.opacity)
                } else {
                    ContentView()
                        .transition(.opacity)
                }

                if breathingService.isActive {
                    VStack {
                        Spacer()
                        BreathingTimerView(service: breathingService)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring, value: breathingService.isActive)
                    .ignoresSafeArea(.keyboard)
                }
            }
            .environmentObject(breathingService)
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
