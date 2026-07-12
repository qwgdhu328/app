import SwiftUI

struct HomeView: View {
    @State private var selectedMood: String? = nil
    @State private var showAffirmation = false
    @State private var streak = 0
    @AppStorage("lastActiveDate") private var lastActiveDate: String = ""

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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
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
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var streakSection: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text("\(streak) giorni di fila!")
                .font(.subheadline.weight(.medium))
            Spacer()
            if streak > 0 {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
            }
        }
        .padding(12)
        .background(AppColors.cardBg)
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
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(emoji)
                                .font(.system(size: 32))
                                .scaleEffect(selectedMood == emoji ? 1.3 : 1.0)
                            Text(label)
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(selectedMood == emoji ? AnyShapeStyle(AppTint.opacity(0.15)) : AnyShapeStyle(AppColors.cardBg))
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(
                            selectedMood == emoji ?
                            RoundedRectangle(cornerRadius: 16).stroke(AppTint, lineWidth: 2) : nil
                        )
                    }
                }
            }
        }
    }

    private var affirmationCard: some View {
        HStack {
            Image(systemName: "quote.opening")
                .foregroundStyle(AppColors.breathingAccent)
            Text(dailyAffirmation)
                .font(.subheadline).italic()
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            Image(systemName: "quote.closing")
                .foregroundStyle(AppColors.breathingAccent)
        }
        .cardBg()
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Esplora")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                actionCard(icon: "brain.head.profile", title: "Mindfulness", color: Color(red: 0.5, green: 0.7, blue: 1.0)) {
                    dailyAffirmation = "Chiudi gli occhi. Respira. Sii presente. 🌿"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "figure.walk", title: "Passeggiata", color: Color(red: 0.4, green: 0.85, blue: 0.6)) {
                    dailyAffirmation = "Immagina di camminare in una foresta. 🚶"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "book.closed", title: "Diario rapido", color: Color(red: 1.0, green: 0.7, blue: 0.4)) {
                    dailyAffirmation = "Scrivi 3 cose positive della tua giornata. 📝"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "music.note", title: "Musica rilassante", color: Color(red: 0.7, green: 0.4, blue: 1.0)) {
                    dailyAffirmation = "Ascolta un brano che ami. 🎵"
                    withAnimation { showAffirmation = true }
                }
            }
        }
    }

    private func actionCard(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(AppColors.cardBg)
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
                    .foregroundStyle(AppColors.breathingAccent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Respiro guidato")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(breathingService.isActive ? "In corso..." : "Scegli pattern e durata")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: breathingService.isActive ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppColors.breathingAccent)
            }
            .cardBg()
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
