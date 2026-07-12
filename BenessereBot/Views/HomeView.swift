import SwiftUI

struct HomeView: View {
    @StateObject private var streakManager = StreakManager()
    @State private var selectedMood: String? = nil
    @State private var showAffirmation = false
    @State private var dailyAffirmation = ""

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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingSection
                    streakSection
                    moodSection
                    if showAffirmation {
                        affirmationCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    quickActionsSection
                    breathingSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(AppBackground())
            .navigationTitle("BenessereBot")
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
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
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var streakSection: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text("\(streakManager.streak) giorni di fila!")
                .font(.subheadline.weight(.medium))
                .contentTransition(.numericText())
            Spacer()
            if streakManager.streak > 0 {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
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
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selectedMood = emoji
                            showAffirmation = true
                            streakManager.updateStreak()
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(emoji)
                                .font(.system(size: 32))
                                .scaleEffect(selectedMood == emoji ? 1.4 : 1.0)
                                .opacity(selectedMood == emoji ? 1.0 : 0.8)
                            Text(label)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(selectedMood == emoji ? AppTint.opacity(0.2) : .regularMaterial)
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
                .foregroundStyle(AppTint)
            Text(dailyAffirmation)
                .font(.subheadline.italic)
                .multilineTextAlignment(.center)
            Image(systemName: "quote.closing")
                .foregroundStyle(AppTint)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
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
                actionCard(icon: "figure.walk", title: "Passeggiata", color: .green) {
                    dailyAffirmation = "Immagina di camminare in una foresta. Senti l'aria fresca. 🚶"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "book.closed", title: "Diario rapido", color: .orange) {
                    dailyAffirmation = "Scrivi 3 cose positive della tua giornata. 📝"
                    withAnimation { showAffirmation = true }
                }
                actionCard(icon: "music.note", title: "Musica rilassante", color: .purple) {
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
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var breathingSection: some View {
        VStack(spacing: 12) {
            Text("Respiro guidato")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                startBreathing()
            } label: {
                HStack {
                    Image(systemName: "wind")
                        .font(.title2)
                        .foregroundStyle(.teal)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Timer di respiro")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.primary)
                        Text("1 minuto di respiro consapevole")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.teal)
                }
                .padding(16)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 16))
            }
        }
    }

    private func startBreathing() {
        dailyAffirmation = "Inspira...  🌬️\nEspira...  🌬️\nRipeti per 1 minuto."
        withAnimation { showAffirmation = true }
    }
}

#Preview {
    HomeView()
}
