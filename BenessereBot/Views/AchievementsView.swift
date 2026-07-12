import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query var achievements: [Achievement]
    @Environment(\.modelContext) var context

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(achievements) { a in
                            VStack(spacing: 10) {
                                Image(systemName: a.icon)
                                    .font(.title)
                                    .foregroundStyle(a.isUnlocked ? Theme.accent : Theme.muted)
                                    .symbolEffect(.bounce, value: a.isUnlocked)
                                Text(a.title).font(.caption.weight(.medium)).foregroundStyle(Theme.text).multilineTextAlignment(.center)
                                Text(a.details).font(.caption2).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Theme.card)
                            .clipShape(.rect(cornerRadius: 16))
                            .overlay(a.isUnlocked ? RoundedRectangle(cornerRadius: 16).stroke(Theme.accent.opacity(0.5), lineWidth: 1) : nil)
                            .opacity(a.isUnlocked ? 1 : 0.5)
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
}
