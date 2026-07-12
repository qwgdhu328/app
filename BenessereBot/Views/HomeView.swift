import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var selectedMood: String? = nil
    @State private var showAffirmation = false
    @State private var dailyAffirmation: String = ""
    @State private var animateItems = false
    @AppStorage("streak") private var streak = 0
    @AppStorage("lastActiveDate") private var lastActiveDate: String = ""
    @Query var moodEntries: [MoodEntry]
    @Query var entries: [JournalEntry]
    @Query var sessions: [BreathingSession]
    @Environment(\.modelContext) var context
    @EnvironmentObject var breathingService: BreathingService

    private let moodGrid = [
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    wellnessRingSection
                        .offset(y: animateItems ? 0 : 40).opacity(animateItems ? 1 : 0)
                    greetingSection
                        .offset(y: animateItems ? 0 : 30).opacity(animateItems ? 1 : 0)
                    streakSection
                        .offset(y: animateItems ? 0 : 20).opacity(animateItems ? 1 : 0)
                    moodSection
                        .offset(y: animateItems ? 0 : 20).opacity(animateItems ? 1 : 0)
                    if showAffirmation { affirmationCard }
                    quickActionsSection
                        .offset(y: animateItems ? 0 : 20).opacity(animateItems ? 1 : 0)
                    breathingSection
                        .offset(y: animateItems ? 0 : 20).opacity(animateItems ? 1 : 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(AppBackground())
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                checkStreak()
                dailyAffirmation = affirmations.randomElement() ?? affirmations[0]
                withAnimation(.easeOut(duration: 0.8)) { animateItems = true }
            }
            .onDisappear { animateItems = false }
        }
    }

    private var wellnessRingSection: some View {
        let score = computeWellnessScore(moods: moodEntries.count, streak: streak, sessions: sessions.count, entries: entries.count)
        return HStack(spacing: 20) {
            ZStack {
                Circle().stroke(Theme.cardBorder, lineWidth: 8).frame(width: 72, height: 72)
                Circle()
                    .trim(from: 0, to: Double(score) / 100)
                    .stroke(scoreColor(score), style: .init(lineWidth: 8, lineCap: .round))
                    .frame(width: 72, height: 72).rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1, dampingFraction: 0.6), value: score)
                Text("\(score)").font(.title3.weight(.bold)).foregroundStyle(Theme.text)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Benessere").font(.headline).foregroundStyle(Theme.text)
                let label: String = {
                    if let last = moodEntries.last { return "\(last.emoji) \(last.label)" }
                    if let last = entries.last { return "Ultimo pensiero: \(last.date.formatted(date: .abbreviated, time: .omitted))" }
                    return "Inizia il tuo percorso"
                }()
                Text(label).font(.subheadline).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .glass()
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            let hour = Calendar.current.component(.hour, from: Date())
            let greeting: String = {
                switch hour { case 6..<12: return "Buongiorno"; case 12..<18: return "Buon pomeriggio"; default: return "Buonasera" }
            }()
            Text("\(greeting)! 👋").font(.largeTitle.weight(.bold)).foregroundStyle(Theme.text)
            Text("Come stai oggi?").font(.title3).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var streakSection: some View {
        HStack {
            Image(systemName: "flame.fill").font(.title3).foregroundStyle(Theme.accentSecondary)
            Text("\(streak) giorni di fila!").font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
            Spacer()
            if streak > 0 { Image(systemName: "sparkles").foregroundStyle(Theme.accentSecondary) }
        }
        .glass()
    }

    private var moodSection: some View {
        VStack(spacing: 16) {
            Text("Come ti senti?").font(.headline).foregroundStyle(Theme.text).frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(moodGrid, id: \.0) { emoji, label in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selectedMood = emoji; showAffirmation = true; updateStreak()
                            let entry = MoodEntry(emoji: emoji, label: label, score: (moodGrid.firstIndex(where: { $0.0 == emoji }).map { ($0 + 1) * 20 } ?? 50))
                            context.insert(entry); try? context.save()
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(emoji).font(.system(size: 32)).scaleEffect(selectedMood == emoji ? 1.3 : 1)
                            Text(label).font(.caption2).foregroundStyle(Theme.muted)
                        }
                        .frame(maxWidth: .infinity).padding(12)
                        .background(selectedMood == emoji ? Theme.accent.opacity(0.15) : Theme.surface)
                        .background(selectedMood == emoji ? AnyShapeStyle(Theme.glassGradient) : AnyShapeStyle(Color.clear))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(selectedMood == emoji ? Theme.cardBorderHighlight : Theme.cardBorder, lineWidth: 1))
                    }
                }
            }
        }
        .glass()
    }

    private var affirmationCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "quote.opening").font(.title3).foregroundStyle(Theme.accent)
            Text(dailyAffirmation).font(.subheadline).italic().foregroundStyle(Theme.text).multilineTextAlignment(.center)
            Image(systemName: "quote.closing").font(.title3).foregroundStyle(Theme.accent)
        }
        .glass()
        .transition(.scale.combined(with: .opacity))
    }

    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            Text("Esplora").font(.headline).foregroundStyle(Theme.text).frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ActionCard(icon: "brain.head.profile", title: "Mindfulness") {
                    dailyAffirmation = "Chiudi gli occhi. Respira. Sii presente. 🌿"
                    withAnimation { showAffirmation = true }
                }
                ActionCard(icon: "figure.walk", title: "Passeggiata") {
                    dailyAffirmation = "Immagina di camminare in una foresta. 🚶"
                    withAnimation { showAffirmation = true }
                }
                ActionCard(icon: "book.closed", title: "Diario rapido") {
                    dailyAffirmation = "Scrivi 3 cose positive della tua giornata. 📝"
                    withAnimation { showAffirmation = true }
                }
                ActionCard(icon: "music.note", title: "Musica rilassante") {
                    dailyAffirmation = "Ascolta un brano che ami. 🎵"
                    withAnimation { showAffirmation = true }
                }
            }
        }
    }

    private var breathingSection: some View {
        Button {
            breathingService.pattern = .simple; breathingService.rounds = 3; breathingService.start()
        } label: {
            HStack {
                Image(systemName: "wind").font(.title2).foregroundStyle(Theme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Respiro guidato").font(.callout.weight(.semibold)).foregroundStyle(Theme.text)
                    Text(breathingService.isActive ? "In corso..." : "Scegli pattern e durata").font(.caption).foregroundStyle(Theme.muted)
                }
                Spacer()
                Image(systemName: breathingService.isActive ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title2).foregroundStyle(Theme.accent)
            }
            .glass()
        }
    }

    private func scoreColor(_ s: Int) -> Color { s >= 80 ? Theme.accent : s >= 50 ? Theme.accentSecondary : .red.opacity(0.7) }
    private func checkStreak() {
        let today = formattedDate(Date())
        if lastActiveDate != today {
            let cal = Calendar.current
            if let last = dateFromString(lastActiveDate), let diff = cal.dateComponents([.day], from: last, to: Date()).day {
                streak = diff <= 1 ? streak + 1 : 0
            } else { streak = 1 }
            lastActiveDate = today
        }
    }
    private func updateStreak() {
        let today = formattedDate(Date())
        if lastActiveDate != today { streak += 1; lastActiveDate = today }
    }
    private func formattedDate(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d) }
    private func dateFromString(_ s: String) -> Date? { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.date(from: s) }
}

struct ActionCard: View {
    let icon: String; let title: String; let action: () -> Void
    @State private var pressed = false
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon).font(.title2).foregroundStyle(Theme.accent)
                Text(title).font(.callout.weight(.semibold)).foregroundStyle(Theme.text)
            }
            .frame(maxWidth: .infinity).padding(16)
            .background(Theme.surface).background(Theme.glassGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
        }
        .scaleEffect(pressed ? 0.95 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pressed)
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in pressed = true }.onEnded { _ in pressed = false })
    }
}
