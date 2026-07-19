import SwiftUI

struct IntroView: View {
    @Binding var showIntro: Bool
    @State private var currentPage = 0
    @State private var name = ""
    @State private var selectedGoal: String? = nil
    @State private var selectedMood: String? = nil
    @State private var animateContent = false

    private let goals = [
        ("Gestire l'ansia", "brain.head.profile"),
        ("Migliorare l'umore", "sun.max.fill"),
        ("Trova equilibrio", "scales.3d"),
        ("Crescita personale", "arrow.up.heart.fill"),
        ("Relazioni migliori", "heart.fill"),
        ("Sonno e riposo", "moon.stars.fill")
    ]

    private let features: [(icon: String, title: String, desc: String)] = [
        ("brain.head.profile", "Parla con BenessereBot", "Uno psicologo AI sempre pronto ad ascoltarti. Condividi pensieri ed emozioni in un ambiente sicuro."),
        ("face.smiling.fill", "Traccia il tuo umore", "Registra come ti senti ogni giorno. Visualizza il tuo percorso di benessere con statistiche e grafici."),
        ("wind", "Respira con calma", "Esercizi di respiro guidato. Ritrova la calma in qualsiasi momento."),
        ("book.fill", "Diario personale", "Scrivi i tuoi pensieri con prompt guidati. Rileggi il tuo percorso."),
        ("sparkles", "Il tuo viaggio inizia", "Affermazioni quotidiane, obiettivi, trofei. BenessereBot è il tuo compagno per il benessere mentale.")
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, Theme.bgMid, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            RadialGradient(colors: [Theme.accent.opacity(0.06), .clear], center: .top, startRadius: 0, endRadius: 400)
                .ignoresSafeArea()
            RadialGradient(colors: [Theme.accentSecondary.opacity(0.04), .clear], center: .bottom, startRadius: 0, endRadius: 400)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<features.count, id: \.self) { i in
                        featurePage(index: i).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                bottomBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { animateContent = true }
        }
    }

    private func featurePage(index: Int) -> some View {
        let f = features[safe: index] ?? features[0]
        return VStack(spacing: 0) {
            Spacer(minLength: 60)

            ZStack {
                Circle().fill(Theme.gradientAccent.opacity(0.1)).frame(width: 140, height: 140)
                Circle().fill(Theme.gradientAccent.opacity(0.05)).frame(width: 100, height: 100)
                Image(systemName: f.icon)
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.gradientAccent)
                    .symbolEffect(.bounce, value: currentPage)
            }
            .padding(.bottom, 40)

            Text(f.title)
                .font(.title.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 16)

            Text(f.desc)
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)

            if index == 0 { nameSection }
            if index == 1 { goalSection }
            if index == 2 { moodSection }

            Spacer()
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }

    private var nameSection: some View {
        VStack(spacing: 12) {
            TextField("Il tuo nome...", text: $name)
                .textFieldStyle(.plain)
                .font(.title3)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(14)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: 1))
                .padding(.horizontal, 40)
                .padding(.top, 8)

            if !name.isEmpty {
                Text("Piacere, \(name)!")
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var goalSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(goals, id: \.0) { goal, icon in
                Button {
                    withAnimation(.spring) { selectedGoal = goal }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: icon).font(.title3).foregroundStyle(selectedGoal == goal ? .white : Theme.textSecondary)
                        Text(goal).font(.caption.weight(.medium)).foregroundStyle(selectedGoal == goal ? .white : Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(selectedGoal == goal ? Theme.accent : Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedGoal == goal ? Theme.accent.opacity(0.5) : Theme.cardBorder, lineWidth: 1))
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 8)
    }

    private var moodSection: some View {
        HStack(spacing: 12) {
            ForEach(["😊", "😐", "😢", "😡", "😴"], id: \.self) { emoji in
                Button {
                    withAnimation(.spring) { selectedMood = emoji }
                } label: {
                    Text(emoji).font(.system(size: 36))
                        .padding(10)
                        .background(selectedMood == emoji ? Theme.accent.opacity(0.25) : Theme.surface)
                        .clipShape(Circle())
                        .overlay(
                            selectedMood == emoji ?
                            Circle().stroke(Theme.accent, lineWidth: 2) : nil
                        )
                }
            }
        }
        .padding(.top, 12)
    }

    private var bottomBar: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(0..<features.count, id: \.self) { i in
                    Capsule()
                        .fill(currentPage == i ? Theme.gradientAccent : Theme.muted.opacity(0.3))
                        .frame(width: currentPage == i ? 24 : 8, height: 8)
                        .animation(.spring, value: currentPage)
                }
            }

            HStack {
                if currentPage < features.count - 1 {
                    Button("Salta") {
                        completeIntro()
                    }
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                } else {
                    Spacer()
                }

                Spacer()

                Button {
                    withAnimation(.spring) {
                        if currentPage < features.count - 1 {
                            currentPage += 1
                        } else {
                            completeIntro()
                        }
                    }
                } label: {
                    Text(currentPage < features.count - 1 ? "Avanti" : "Inizia")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Theme.accent)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func completeIntro() {
        UserDefaults.standard.set(true, forKey: "hasSeenIntro")
        if !name.isEmpty { UserDefaults.standard.set(name, forKey: "userName") }
        if let goal = selectedGoal { UserDefaults.standard.set(goal, forKey: "userGoal") }
        withAnimation(.easeInOut(duration: 0.4)) {
            showIntro = false
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
