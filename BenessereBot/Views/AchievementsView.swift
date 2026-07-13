import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query var achievements: [Achievement]
    @Environment(\.modelContext) var context

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(achievements) { a in
                        AchievementCell(achievement: a)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Trofei")
        .onAppear {
            if achievements.isEmpty {
                for a in AchievementService.shared.all { context.insert(a) }
                try? context.save()
            }
        }
    }
}

private struct AchievementCell: View {
    let achievement: Achievement
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: achievement.icon).font(.title)
                .foregroundStyle(achievement.isUnlocked ? Theme.accent : Theme.muted)
                .symbolEffect(.bounce, value: achievement.isUnlocked)
            Text(achievement.title).font(.caption.weight(.semibold)).foregroundStyle(Theme.text).multilineTextAlignment(.center)
            Text(achievement.details).font(.caption2).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(achievement.isUnlocked ? Theme.accent.opacity(0.4) : Color.clear, lineWidth: 1)
        }
        .opacity(achievement.isUnlocked ? 1 : 0.5)
    }
}
