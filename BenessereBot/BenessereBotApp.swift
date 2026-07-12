import SwiftUI
import UserNotifications
import SwiftData

@main
struct BenessereBotApp: App {
    @State private var showIntro = !UserDefaults.standard.bool(forKey: "hasSeenIntro")
    @StateObject private var breathingService = BreathingService()
    let modelContainer: ModelContainer

    init() {
        guard let container = try? ModelContainer(
            for: StoredMessage.self, MoodEntry.self, BreathingSession.self,
            JournalEntry.self, Goal.self, Habit.self, Achievement.self
        ) else {
            fatalError("Could not initialize ModelContainer")
        }
        modelContainer = container
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
            .onChange(of: breathingService.isActive) { _, active in
                if !active {
                    let s = breathingService
                    if s.secondsLeft <= 0 {
                        let session = BreathingSession(pattern: s.pattern.rawValue, duration: s.totalDuration, rounds: s.rounds)
                        modelContainer.mainContext.insert(session)
                        try? modelContainer.mainContext.save()
                    }
                }
            }
        }
        .modelContainer(modelContainer)
    }

    private func requestNotificationPermission() {
        Task { try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) }
    }

    private func styleTabBar() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Theme.muted)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.muted)]
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.breathing)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.breathing)]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.titleTextAttributes = [.foregroundColor: UIColor(Theme.text)]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor(Theme.text)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }
}

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
