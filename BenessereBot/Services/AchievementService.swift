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
        let descriptors = FetchDescriptor<Achievement>()
        guard let existing = try? context.fetch(descriptors), existing.isEmpty else { return }
        for a in all { context.insert(a) }
        try? context.save()
    }
}
