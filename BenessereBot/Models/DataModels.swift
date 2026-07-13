import Foundation
import SwiftData

@Model
class ChatSession {
    var id: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var messages: [StoredMessage] = []

    init() {
        self.id = UUID().uuidString
        self.createdAt = Date()
    }
}

@Model
class StoredMessage {
    var id: String
    var role: String
    var content: String
    var timestamp: Date
    var isBookmarked: Bool
    var conversationId: String
    var session: ChatSession?

    init(role: String, content: String, conversationId: String = "main", session: ChatSession? = nil) {
        self.id = UUID().uuidString
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.isBookmarked = false
        self.conversationId = conversationId
        self.session = session
    }
}

@Model
class MoodEntry {
    var id: String
    var moodValue: Int
    var emoji: String
    var label: String
    var note: String
    var date: Date
    var score: Int

    init(moodValue: Int = 0, emoji: String, label: String, note: String = "", score: Int = 0) {
        self.id = UUID().uuidString
        self.moodValue = moodValue
        self.emoji = emoji
        self.label = label
        self.note = String(note.prefix(500))
        self.date = Date()
        self.score = score
    }
}

@Model
class BreathingSession {
    var id: String
    var pattern: String
    var duration: Int
    var rounds: Int
    var date: Date

    init(pattern: String, duration: Int, rounds: Int) {
        self.id = UUID().uuidString
        self.pattern = pattern
        self.duration = duration
        self.rounds = rounds
        self.date = Date()
    }
}

@Model
class JournalEntry {
    var id: String
    var prompt: String
    var content: String
    var date: Date
    var isFavorite: Bool

    init(prompt: String, content: String) {
        self.id = UUID().uuidString
        self.prompt = prompt
        self.content = content
        self.date = Date()
        self.isFavorite = false
    }
}

@Model
class Goal {
    var id: String
    var title: String
    var details: String
    var icon: String
    var progress: Double
    var target: Double
    var createdAt: Date

    init(title: String, details: String = "", icon: String = "target", target: Double = 100) {
        self.id = UUID().uuidString
        self.title = title
        self.details = details
        self.icon = icon
        self.progress = 0
        self.target = target
        self.createdAt = Date()
    }
}

@Model
class Habit {
    var id: String
    var title: String
    var icon: String
    var streak: Int
    var lastCompleted: Date?
    var createdAt: Date

    init(title: String, icon: String = "star.fill") {
        self.id = UUID().uuidString
        self.title = title
        self.icon = icon
        self.streak = 0
        self.createdAt = Date()
    }
}

@Model
class Achievement {
    var id: String
    var title: String
    var details: String
    var icon: String
    var isUnlocked: Bool
    var unlockedAt: Date?

    init(title: String, details: String, icon: String) {
        self.id = UUID().uuidString
        self.title = title
        self.details = details
        self.icon = icon
        self.isUnlocked = false
    }
}
