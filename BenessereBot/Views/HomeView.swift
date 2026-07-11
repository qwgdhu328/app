import SwiftUI

struct HomeView: View {
    @State private var selectedMood: String? = nil
    @State private var showAffirmation = false
    @State private var stepCount = 0
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingSection
                    streakSection
                    moodSection
                    if showAffirmation {
                        affirmationCard
                    }
                    quickActionsSection
                    tipSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("BenessereBot")
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
                .font(.title.bold())
            Text("Come stai oggi?")
                .foregroundStyle(.secondary)
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
                Text("🔥")
                    .font(.caption)
            }
        }
        .padding(12)
        .background(.regularMaterial)
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
                        withAnimation(.spring) {
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
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(selectedMood == emoji ? AppTint.opacity(0.15) : .regularMaterial)
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
                .foregroundStyle(.tint)
            Text(dailyAffirmation)
                .font(.subheadline.italic)
                .multilineTextAlignment(.center)
            Image(systemName: "quote.closing")
                .foregroundStyle(.tint)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .transition(.scale.combined(with: .opacity))
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Esplora")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                actionCard(icon: "brain.head.profile", title: "Mindfulness", color: .blue) {
                    dailyAffirmation = "Chiudi gli occhi. Respira. Sii presente. 🌿"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "figure.walk", title: "Passeggiata virtuale", color: .green) {
                    dailyAffirmation = "Immagina di camminare in una foresta. Senti l'aria fresca. 🚶"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "book.closed", title: "Diario rapido", color: .orange) {
                    dailyAffirmation = "Scrivi 3 cose positive della tua giornata. 📝"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "music.note", title: "Musica rilassante", color: .purple) {
                    dailyAffirmation = "Ascolta un brano che ami. Lascia che la musica ti avvolga. 🎵"
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
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var tipSection: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
            Text("Respirare profondamente per 5 secondi aiuta a ridurre lo stress. Prova ora!")
                .font(.subheadline)
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func checkStreak() {
        let today = formattedDate(Date())
        if lastActiveDate != today {
            let cal = Calendar.current
            if let last = formattedDateToDate(lastActiveDate),
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

    private func formattedDateToDate(_ string: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: string)
    }
}

#Preview {
    HomeView()
}
