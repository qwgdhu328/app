import ActivityKit

struct ReminderActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var reminderMessage: String
    }
    var reminderMessage: String
}
