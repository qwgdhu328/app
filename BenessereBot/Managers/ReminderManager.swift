import Foundation
import UserNotifications

struct ReminderPrefs: Codable {
    var isEnabled = false
    var hour = 9
    var minute = 0
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
class ReminderManager {
    static let shared = ReminderManager()

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
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }

    func checkPermissionAndSchedule() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .authorized { schedule() }
    }
}
