import SwiftUI
import UserNotifications
import SwiftData

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
            .onChange(of: breathingService.isActive) { _, active in
                if !active, let ctx = try? ModelContext(.init(for: BreathingSession.self)) {
                    let s = breathingService
                    if s.secondsLeft <= 0 {
                        let session = BreathingSession(pattern: s.pattern.rawValue, duration: s.totalDuration, rounds: s.rounds)
                        ctx.insert(session); try? ctx.save()
                    }
                }
            }
        }
        .modelContainer(for: [StoredMessage.self, MoodEntry.self, BreathingSession.self, JournalEntry.self, Goal.self, Habit.self, Achievement.self])
    }
}

    private func requestNotificationPermission() {
        Task { try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) }
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.bgTop)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Theme.muted)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.muted)]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.breathing)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.breathing)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(Theme.bgTop)
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
