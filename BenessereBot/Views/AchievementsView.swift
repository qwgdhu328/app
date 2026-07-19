import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query var achievements: [Achievement]
    @Query var moods: [MoodEntry]
    @Query var sessions: [BreathingSession]
    @Query var entries: [JournalEntry]
    @Query var messages: [StoredMessage]
    @AppStorage("streak") private var streak = 0
    @Environment(\.modelContext) var context

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                if achievements.isEmpty {
                    VStack(spacing: 16) {
                        ContentUnavailableView("Nessun trofeo", systemImage: "trophy", description: Text("Completa attività per sbloccare trofei"))
                            .foregroundStyle(Theme.muted)
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(achievements) { a in
                            AchievementCell(achievement: a)
                        }
                    }
                    .padding()
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle("Trofei")
        .onAppear {
            AchievementService.shared.checkAndUnlock(context: context, basedOn: (
                messages: messages.count,
                moods: moods.count,
                sessions: sessions.count,
                entries: entries.count,
                streak: streak,
                hasVisitedAll: false,
                goalsCompleted: 0
            ))
        }
    }
}

private struct AchievementCell: View {
    let achievement: Achievement
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: achievement.icon).font(.title)
                .foregroundStyle(achievement.isUnlocked ? Theme.gold : Theme.muted)
                .symbolEffect(.bounce, value: achievement.isUnlocked)
            Text(achievement.title).font(.caption.weight(.semibold)).foregroundStyle(Theme.text).multilineTextAlignment(.center)
            Text(achievement.details).font(.caption2).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(achievement.isUnlocked ? Theme.gold.opacity(0.4) : Theme.cardBorder, lineWidth: 1)
        }
        .opacity(achievement.isUnlocked ? 1 : 0.5)
    }
}
