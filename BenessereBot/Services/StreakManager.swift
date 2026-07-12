import Foundation
import Combine

@MainActor
class StreakManager: ObservableObject {
    @Published var streak: Int = 0
    @Published var lastActiveDate: String = ""

    private let streakKey = "streakCount"
    private let dateKey = "lastActiveDate"

    init() {
        streak = UserDefaults.standard.integer(forKey: streakKey)
        lastActiveDate = UserDefaults.standard.string(forKey: dateKey) ?? ""
        checkStreak()
    }

    func updateStreak() {
        let today = formattedDate(Date())
        guard lastActiveDate != today else { return }
        streak += 1
        lastActiveDate = today
        save()
    }

    private func checkStreak() {
        let today = formattedDate(Date())
        guard lastActiveDate != today else { return }
        if let last = dateFromString(lastActiveDate),
           let diff = Calendar.current.dateComponents([.day], from: last, to: Date()).day {
            streak = diff <= 1 ? streak + 1 : 0
        } else {
            streak = 1
        }
        lastActiveDate = today
        save()
    }

    private func save() {
        UserDefaults.standard.set(streak, forKey: streakKey)
        UserDefaults.standard.set(lastActiveDate, forKey: dateKey)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func dateFromString(_ string: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: string)
    }
}
