import SwiftUI
import SwiftData

struct WellbeingView: View {
    @Query var moods: [MoodEntry]
    @Query var sessions: [BreathingSession]
    @Query var entries: [JournalEntry]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        statsGrid
                        NavigationLink(destination: MoodCalendarView()) {
                            HStack { Image(systemName: "calendar").foregroundStyle(Theme.accent); Text("Calendario umore").foregroundStyle(Theme.text); Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted) }.card()
                        }
                        NavigationLink(destination: JournalView()) {
                            HStack { Image(systemName: "book.fill").foregroundStyle(Theme.accent); Text("Diario dei pensieri").foregroundStyle(Theme.text); Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted) }.card()
                        }
                        NavigationLink(destination: GoalsListView()) {
                            HStack { Image(systemName: "target").foregroundStyle(Theme.accent); Text("Obiettivi e abitudini").foregroundStyle(Theme.text); Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted) }.card()
                        }
                        NavigationLink(destination: AchievementsView()) {
                            HStack { Image(systemName: "trophy.fill").foregroundStyle(Theme.accent); Text("Trofei").foregroundStyle(Theme.text); Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted) }.card()
                        }
                        if !sessions.isEmpty {
                            NavigationLink(destination: BreathingHistoryView()) {
                                HStack { Image(systemName: "wind").foregroundStyle(Theme.breathing); Text("Storico respiri").foregroundStyle(Theme.text); Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted) }.card()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Benessere")
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statBox(value: "\(moods.count)", label: "Umore", icon: "heart.fill", color: Theme.accent)
            statBox(value: "\(entries.count)", label: "Pensieri", icon: "book.fill", color: Theme.accent)
            statBox(value: "\(sessions.count)", label: "Respiri", icon: "wind", color: Theme.accent)
        }
    }

    private func statBox(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color).font(.title3)
            Text(value).font(.title2.weight(.bold)).foregroundStyle(Theme.text)
            Text(label).font(.caption2).foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Theme.card)
        .clipShape(.rect(cornerRadius: 12))
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
                List {
                    Section("Statistiche") {
                        HStack { Text("Totale minuti").foregroundStyle(Theme.text); Spacer(); Text("\(totalMinutes) min").foregroundStyle(Theme.breathing).bold() }.listRowBackground(Theme.card)
                        HStack { Text("Sessioni totali").foregroundStyle(Theme.text); Spacer(); Text("\(sessions.count)").foregroundStyle(Theme.text).bold() }.listRowBackground(Theme.card)
                    }
                    Section("Cronologia") {
                        ForEach(sessions) { s in
                            HStack {
                                Image(systemName: "wind").foregroundStyle(Theme.breathing)
                                VStack(alignment: .leading) {
                                    Text(s.pattern).font(.headline).foregroundStyle(Theme.text)
                                    Text("\(s.duration)s • \(s.rounds) cicli").font(.caption).foregroundStyle(Theme.muted)
                                }
                                Spacer()
                                Text(s.date.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(Theme.muted)
                            }
                            .listRowBackground(Theme.card)
                        }
                    }
                }
                .listStyle(.insetGrouped).scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Storico respiri")
    }
}
