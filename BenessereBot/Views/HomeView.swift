import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var selectedMood: String? = nil
    @State private var showAffirmation = false
    @AppStorage("streak") private var streak = 0
    @AppStorage("lastActiveDate") private var lastActiveDate: String = ""
    @Query var moodEntries: [MoodEntry]
    @Query var entries: [JournalEntry]
    @Query var sessions: [BreathingSession]
    @Environment(\.modelContext) var context

    private let moods = [
        ("😊", "Felice"), ("😐", "Neutro"), ("😢", "Triste"),
        ("😡", "Arrabbiato"), ("😴", "Stanco"), ("🤗", "Riconoscente")
    ]

    private let affirmations = [
        "Ogni giorno è una nuova opportunità.",
        "Sei più forte di quanto pensi.",
        "Prenditi cura di te, meriti amore.",
        "Il progresso, non la perfezione.",
        "Respira. Sii presente. Sii grato.",
        "Hai già superato tante cose. Continua."
    ]

    @State private var dailyAffirmation: String = ""

    @EnvironmentObject var breathingService: BreathingService

    private var todayLabel: String {
        moodEntries.last.map { "Oggi: \($0.emoji) \($0.label)" } ?? entries.last.map { "Ultimo pensiero: \($0.date.formatted(date: .abbreviated, time: .omitted))" } ?? "Inizia il tuo percorso"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    WellnessScoreView(score: computeWellnessScore(moods: moodEntries.count, streak: streak, sessions: sessions.count, entries: entries.count), label: todayLabel)
                    greetingSection
                    streakSection
                    moodSection
                    if showAffirmation {
                        affirmationCard
                    }
                    quickActionsSection
                    breathingSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(AppBackground())
            .navigationTitle("BenessereBot")
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                checkStreak()
                dailyAffirmation = affirmations.randomElement() ?? affirmations[0]
            }
        }
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            let hour = Calendar.current.component(.hour, from: Date())
            let greeting: String = {
                switch hour {
                case 6..<12: return "Buongiorno"
                case 12..<18: return "Buon pomeriggio"
                default: return "Buonasera"
                }
            }()
            Text("\(greeting)! 👋")
                .font(.largeTitle.bold())
            Text("Come stai oggi?")
                .font(.title3)
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var streakSection: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundStyle(Theme.accent)
            Text("\(streak) giorni di fila!")
                .font(.subheadline.weight(.medium))
            Spacer()
            if streak > 0 {
                Image(systemName: "sparkles")
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(12)
        .background(Theme.card)
        .clipShape(.rect(cornerRadius: 12))
    }

    private var moodSection: some View {
        VStack(spacing: 12) {
            Text("Come ti senti?")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(moods, id: \.0) { emoji, label in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selectedMood = emoji
                            showAffirmation = true
                            updateStreak()
                            let moodEntry = MoodEntry(emoji: emoji, label: label, score: (moods.firstIndex(where: { $0.0 == emoji }).map { ($0 + 1) * 20 } ?? 50))
                            context.insert(moodEntry)
                            try? context.save()
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(emoji)
                                .font(.system(size: 32))
                                .scaleEffect(selectedMood == emoji ? 1.3 : 1.0)
                            Text(label)
                                .font(.caption2)
                                .foregroundStyle(Theme.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(selectedMood == emoji ? AnyShapeStyle(Theme.accent.opacity(0.15)) : AnyShapeStyle(Theme.card))
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(
                            selectedMood == emoji ?
                            RoundedRectangle(cornerRadius: 16).stroke(Theme.accent, lineWidth: 2) : nil
                        )
                    }
                }
            }
        }
    }

    private var affirmationCard: some View {
        HStack {
            Image(systemName: "quote.opening")
                .foregroundStyle(Theme.breathing)
            Text(dailyAffirmation)
                .font(.subheadline).italic()
                .foregroundStyle(Theme.text)
                .multilineTextAlignment(.center)
            Image(systemName: "quote.closing")
                .foregroundStyle(Theme.breathing)
        }
        .card()
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Esplora")
                .font(.headline)
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                actionCard(icon: "brain.head.profile", title: "Mindfulness") {
                    dailyAffirmation = "Chiudi gli occhi. Respira. Sii presente. 🌿"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "figure.walk", title: "Passeggiata") {
                    dailyAffirmation = "Immagina di camminare in una foresta. 🚶"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "book.closed", title: "Diario rapido") {
                    dailyAffirmation = "Scrivi 3 cose positive della tua giornata. 📝"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "music.note", title: "Musica rilassante") {
                    dailyAffirmation = "Ascolta un brano che ami. 🎵"
                    withAnimation { showAffirmation = true }
                }
            }
        }
    }

    private func actionCard(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Theme.accent)
                Text(title)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(Theme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Theme.card)
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var breathingSection: some View {
        Button {
            breathingService.pattern = .simple
            breathingService.rounds = 3
            breathingService.start()
        } label: {
            HStack {
                Image(systemName: "wind")
                    .font(.title2)
                    .foregroundStyle(Theme.breathing)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Respiro guidato")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(Theme.text)
                    Text(breathingService.isActive ? "In corso..." : "Scegli pattern e durata")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Image(systemName: breathingService.isActive ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.breathing)
            }
            .card()
        }
    }

    private func checkStreak() {
        let today = formattedDate(Date())
        if lastActiveDate != today {
            let cal = Calendar.current
            if let last = dateFromString(lastActiveDate),
               let diff = cal.dateComponents([.day], from: last, to: Date()).day {
                streak = diff <= 1 ? streak + 1 : 0
            } else {
                streak = 1
            }
            lastActiveDate = today
        }
    }

    private func updateStreak() {
        let today = formattedDate(Date())
        if lastActiveDate != today {
            streak += 1
            lastActiveDate = today
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func dateFromString(_ string: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: string)
    }
}

#Preview {
    HomeView()
}
