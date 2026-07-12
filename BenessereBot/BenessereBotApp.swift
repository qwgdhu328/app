import SwiftUI
import UserNotifications

@main
struct BenessereBotApp: App {
    @State private var showIntro = !UserDefaults.standard.bool(forKey: "hasSeenIntro")
    @StateObject private var breathingService = BreathingService()

    init() {
        requestNotificationPermission()
        styleTabBar()
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

    private func requestNotificationPermission() {
        Task {
            try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        }
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(red: 0.08, green: 0.09, blue: 0.15))
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textSecondary)]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.breathingAccent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColors.breathingAccent)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
