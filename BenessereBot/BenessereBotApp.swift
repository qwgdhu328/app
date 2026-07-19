import SwiftUI
import UserNotifications
import SwiftData

@main
struct BenessereBotApp: App {
    @State private var showIntro = !UserDefaults.standard.bool(forKey: "hasSeenIntro")
    @State private var showDownload = !LocalLLMService.shared.modelExists
    @StateObject private var breathingService = BreathingService()
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            ChatSession.self, StoredMessage.self, MoodEntry.self, BreathingSession.self,
            JournalEntry.self, Goal.self, Habit.self, Achievement.self
        ])
        let config = ModelConfiguration("BenessereBot_v2", schema: schema, isStoredInMemoryOnly: false)
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
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
                if showDownload {
                    ModelDownloadView(onComplete: { showDownload = false })
                        .transition(.opacity)
                } else if showIntro {
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
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.accent)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.accent)]
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


