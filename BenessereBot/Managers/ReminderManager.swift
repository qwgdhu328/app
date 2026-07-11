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
class ReminderManager: NSObject {
    static let shared = ReminderManager()

    private override init() {
        super.init()
    }

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func schedule() {
        cancelAll()
        let prefs = ReminderPrefs.stored
        guard prefs.isEnabled else { return }

        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "BenessereBot"
        content.body = prefs.message
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = prefs.hour
        dateComponents.minute = prefs.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: prefs.repeatDaily)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        center.add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }

    func checkPermissionAndSchedule() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized {
            schedule()
        }
    }
}
