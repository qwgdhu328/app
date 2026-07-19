import Foundation
import SwiftData

@MainActor
class AchievementService {
    static let shared = AchievementService()

    let all: [Achievement] = [
        Achievement(title: "Primo messaggio", details: "Invia il tuo primo messaggio in chat", icon: "message.fill"),
        Achievement(title: "Primo umore", details: "Registra il tuo primo umore", icon: "heart.fill"),
        Achievement(title: "Respiro completo", details: "Completa il tuo primo esercizio di respiro", icon: "wind"),
        Achievement(title: "Diario", details: "Scrivi il tuo primo pensiero nel diario", icon: "book.fill"),
        Achievement(title: "Costante", details: "Usa l'app per 7 giorni consecutivi", icon: "flame.fill"),
        Achievement(title: "Esploratore", details: "Visita tutte le sezioni dell'app", icon: "globe"),
        Achievement(title: "Obiettivo raggiunto", details: "Completa il tuo primo obiettivo", icon: "target"),
        Achievement(title: "Community", details: "Interagisci con la community", icon: "person.3.fill"),
        Achievement(title: "10 messaggi", details: "Invia 10 messaggi in chat", icon: "bubble.left.and.bubble.right.fill"),
        Achievement(title: "Dedicato", details: "30 giorni di utilizzo", icon: "star.fill"),
    ]

    func checkAndUnlock(context: ModelContext, basedOn stats: (messages: Int, moods: Int, sessions: Int, entries: Int, streak: Int, hasVisitedAll: Bool, goalsCompleted: Int)) {
        guard let existing = try? context.fetch(FetchDescriptor<Achievement>()), !existing.isEmpty else {
            for a in all { context.insert(a) }
            try? context.save()
            return
        }

        let checks: [(index: Int, condition: Bool)] = [
            (0, stats.messages >= 1),
            (1, stats.moods >= 1),
            (2, stats.sessions >= 1),
            (3, stats.entries >= 1),
            (4, stats.streak >= 7),
            (5, stats.hasVisitedAll),
            (6, stats.goalsCompleted >= 1),
            (7, false),
            (8, stats.messages >= 10),
            (9, stats.streak >= 30),
        ]

        for (i, condition) in checks {
            guard i < existing.count, condition, !existing[i].isUnlocked else { continue }
            existing[i].isUnlocked = true
            existing[i].unlockedAt = Date()
        }
        try? context.save()
    }
}
