import Foundation
import UserNotifications
import ActivityKit

struct ReminderPrefs: Codable {
    var isEnabled = false
    var hour = 9
    var minute = 0
    var useDynamicIsland = true
    var message = "È ora di parlare con BenessereBot \u{1F33F}"
    var repeatDaily = true

    static let key = "reminderPrefs"
    static var stored: ReminderPrefs {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let val = try? JSONDecoder().decode(ReminderPrefs.self, from: data)
            else { return ReminderPrefs() }
            return val
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

@MainActor
class ReminderManager: NSObject {
    static let shared = ReminderManager()
    private var currentActivity: Activity<ReminderActivityAttributes>?

    private override init() { super.init() }

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch { return false }
    }

    func schedule() {
        cancelAll()
        let prefs = ReminderPrefs.stored
        guard prefs.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "BenessereBot"
        content.body = prefs.message
        content.sound = .default

        var dc = DateComponents()
        dc.hour = prefs.hour
        dc.minute = prefs.minute

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "dailyReminder",
                                  content: content,
                                  trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: prefs.repeatDaily))
        )

        if prefs.useDynamicIsland {
            startLiveActivity(prefs)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
        endLiveActivity()
    }

    func checkPermissionAndSchedule() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .authorized { schedule() }
    }

    private func startLiveActivity(_ prefs: ReminderPrefs) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = ReminderActivityAttributes(reminderMessage: prefs.message)
        let state = ReminderActivityAttributes.ContentState(reminderMessage: prefs.message)
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: Date().addingTimeInterval(3600))
            )
        } catch { currentActivity = nil }
    }

    private func endLiveActivity() {
        Task { await currentActivity?.end(dismissalPolicy: .immediate); currentActivity = nil }
    }
}
