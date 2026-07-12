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
    @State private var animateHero = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        heroSection
                            .offset(y: animateHero ? 0 : 40).opacity(animateHero ? 1 : 0)
                        statsRow
                            .offset(y: animateHero ? 0 : 20).opacity(animateHero ? 1 : 0)
                        VStack(spacing: 8) {
                            navLink(icon: "target", title: "Obiettivi", destination: GoalsListView())
                            navLink(icon: "trophy.fill", title: "Trofei", destination: AchievementsView())
                            navLink(icon: "wind", title: "Storico respiri", destination: BreathingHistoryView())
                            Button { showFeatures = true } label: {
                                HStack {
                                    Image(systemName: "sparkles.rectangle.stack").font(.title3).foregroundStyle(Theme.accent).frame(width: 28)
                                    Text("Scopri le funzioni").font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted)
                                }
                                .glass()
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showFeatures) { FeatureIntroView() }
            .onAppear { withAnimation(.easeOut(duration: 0.8)) { animateHero = true } }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(Theme.accent.opacity(0.1)).frame(width: 88, height: 88)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72)).foregroundStyle(Theme.accent.opacity(0.4))
            }
            Text(userName.isEmpty ? "Il tuo profilo" : userName).font(.title2.weight(.bold)).foregroundStyle(Theme.text)
            if !userGoal.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").font(.caption).foregroundStyle(Theme.accentSecondary)
                    Text(userGoal).font(.subheadline).foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .glass()
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCircle(value: moods.count, label: "Umore", icon: "heart.fill")
            statCircle(value: streak, label: "Giorni", icon: "flame.fill")
            statCircle(value: entries.count, label: "Pensieri", icon: "book.fill")
        }
    }

    private func statCircle(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(Theme.accent)
            Text("\(value)").font(.title2.weight(.bold)).foregroundStyle(Theme.text)
            Text(label).font(.caption2).foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity).padding(14)
        .background(Theme.surface).background(Theme.glassGradient)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(.rect(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private func navLink<D: View>(icon: String, title: String, destination: D) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon).font(.title3).foregroundStyle(Theme.accent).frame(width: 28)
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted)
            }
            .glass()
        }
    }
}
