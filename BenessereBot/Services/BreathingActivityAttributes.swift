import ActivityKit
import Foundation

struct BreathingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var phase: String
        var secondsLeft: Int
        var progress: Double
    }

    var startedAt: Date
    var pattern: String
    var totalMinutes: Int
}
