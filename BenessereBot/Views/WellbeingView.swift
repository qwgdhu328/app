import SwiftUI
import SwiftData

struct WellbeingView: View {
    @Query var moods: [MoodEntry]
    @Query var sessions: [BreathingSession]
    @Query var entries: [JournalEntry]
    @State private var animateStats = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        statsGrid
                        navCard(icon: "calendar", title: "Calendario umore", color: Theme.accent, destination: MoodCalendarView())
                        navCard(icon: "book.fill", title: "Diario dei pensieri", color: Theme.accent, destination: JournalView())
                        navCard(icon: "target", title: "Obiettivi e abitudini", color: Theme.accent, destination: GoalsListView())
                        navCard(icon: "trophy.fill", title: "Trofei", color: Theme.accent, destination: AchievementsView())
                        if !sessions.isEmpty {
                            navCard(icon: "wind", title: "Storico respiri", color: Theme.accent, destination: BreathingHistoryView())
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Benessere")
            .onAppear { withAnimation(.easeOut(duration: 0.6)) { animateStats = true } }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statBox(value: moods.count, label: "Umore", icon: "heart.fill")
            statBox(value: entries.count, label: "Pensieri", icon: "book.fill")
            statBox(value: sessions.count, label: "Respiri", icon: "wind")
        }
    }

    private func statBox(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(Theme.accent)
            Text("\(value)").font(.title2.weight(.bold)).foregroundStyle(Theme.text)
                .contentTransition(.numericText())
            Text(label).font(.caption2).foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity).padding(14)
        .background(Theme.surface).background(Theme.glassGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
        .scaleEffect(animateStats ? 1 : 0.8)
        .opacity(animateStats ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: animateStats)
    }

    private func navCard<D: View>(icon: String, title: String, color: Color, destination: D) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon).font(.title3).foregroundStyle(color).frame(width: 28)
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted)
            }
            .glass()
        }
    }
}

struct BreathingHistoryView: View {
    @Query(sort: \BreathingSession.date, order: .reverse) var sessions: [BreathingSession]
    var totalMinutes: Int { sessions.reduce(0) { $0 + $1.duration } / 60 }

    var body: some View {
        ZStack {
            AppBackground()
            if sessions.isEmpty {
                ContentUnavailableView("Nessuna sessione", systemImage: "wind", description: Text("Completa un esercizio di respiro per vederlo qui")).foregroundStyle(Theme.muted)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            statPill("Totale minuti", value: "\(totalMinutes) min", color: Theme.accent)
                            statPill("Sessioni totali", value: "\(sessions.count)", color: Theme.text)
                        }
                        LazyVStack(spacing: 8) {
                            ForEach(sessions) { s in
                                HStack {
                                    Image(systemName: "wind").foregroundStyle(Theme.accent)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(s.pattern).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                                        Text("\(s.duration)s • \(s.rounds) cicli").font(.caption).foregroundStyle(Theme.muted)
                                    }
                                    Spacer()
                                    Text(s.date.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(Theme.muted)
                                }
                                .glass()
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Storico respiri")
    }

    private func statPill(_ label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title3.weight(.bold)).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity).padding(12)
        .background(Theme.surface).background(Theme.glassGradient)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: 1))
    }
}
