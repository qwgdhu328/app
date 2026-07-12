import SwiftUI
import SwiftData

struct ProfileView: View {
    @State private var showFeatures = false
    @AppStorage("userName") private var userName = ""
    @AppStorage("userGoal") private var userGoal = ""
    @Query var moods: [MoodEntry]
    @Query var sessions: [BreathingSession]
    @Query var entries: [JournalEntry]
    @AppStorage("streak") private var streak = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(Theme.accent.opacity(0.4))
                        Text(userName.isEmpty ? "Il tuo profilo" : userName)
                            .font(.title2.bold())
                        Text("Obiettivo: \(userGoal.isEmpty ? "Non impostato" : userGoal)")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section("Statistiche") {
                    HStack(spacing: 12) {
                        statCard(value: "\(moods.count)", label: "Umore", icon: "heart.fill")
                        statCard(value: "\(streak)", label: "Giorni", icon: "flame.fill")
                        statCard(value: "\(entries.count)", label: "Pensieri", icon: "book.fill")
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    Button { showFeatures = true } label: {
                        Label("Scopri le funzioni", systemImage: "sparkles.rectangle.stack")
                    }
                    NavigationLink(destination: GoalsListView()) {
                        Label("Obiettivi", systemImage: "target")
                    }
                    NavigationLink(destination: AchievementsView()) {
                        Label("Trofei", systemImage: "trophy.fill")
                    }
                    NavigationLink(destination: BreathingHistoryView()) {
                        Label("Storico respiri", systemImage: "wind")
                    }
                }


            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Profilo")
            .sheet(isPresented: $showFeatures) { FeatureIntroView() }
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(Theme.accent)
            Text(value).font(.title2.bold()).foregroundStyle(Theme.text)
            Text(label).font(.caption).foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Theme.card)
        .clipShape(.rect(cornerRadius: 16))
    }
}
