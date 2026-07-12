import SwiftUI

struct IntroView: View {
    @Binding var showIntro: Bool
    @State private var currentPage = 0
    @State private var animateContent = false
    @State private var name = ""
    @State private var selectedGoal: String? = nil
    @State private var selectedMood: String? = nil

    private let goals = [
        ("Gestire l'ansia", "brain.head.profile"),
        ("Migliorare l'umore", "sun.max.fill"),
        ("Trova equilibrio", "scales.3d"),
        ("Crescita personale", "arrow.up.heart.fill"),
        ("Relazioni migliori", "heart.fill"),
        ("Sonno e riposo", "moon.stars.fill")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Theme.accent.opacity(0.08), Color(.systemBackground).opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                switch currentPage {
                case 0: welcomePage
                case 1: namePage
                case 2: goalPage
                case 3: moodPage
                case 4: finalPage
                default: welcomePage
                }

                Spacer()

                if currentPage < 4 {
                    HStack {
                        Button("Salta") {
                            withAnimation {
                                showIntro = false
                                UserDefaults.standard.set(true, forKey: "hasSeenIntro")
                            }
                        }
                        .font(.subheadline)

                        Spacer()

                        HStack(spacing: 6) {
                            ForEach(0..<5) { i in
                                Circle()
                                    .fill(currentPage >= i ? Theme.accent : Color.gray.opacity(0.3))
                                    .frame(width: currentPage == i ? 10 : 6, height: currentPage == i ? 10 : 6)
                                    .animation(.spring, value: currentPage)
                            }
                        }

                        Spacer()

                        Button {
                            withAnimation(.spring) {
                                if currentPage < 4 { currentPage += 1 }
                            }
                        } label: {
                            Text(currentPage < 4 ? "Avanti" : "")
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(Theme.accent)
                

            Text("Benvenuto su\nBenessereBot")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Il tuo compagno per il benessere mentale.\nParla, esplora, cresci.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.muted)
                .font(.body)

            Text("Swipe per iniziare →")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 20)
        }
        .padding(30)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }

    private var namePage: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(Theme.accent)
                

            Text("Come ti chiami?")
                .font(.title.bold())

            Text("Così posso rivolgermi a te personalmente.")
                .foregroundStyle(Theme.muted)

            TextField("Il tuo nome...", text: $name)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if !name.isEmpty {
                Text("Piacere di conoscerti, \(name)! ✨")
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(30)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }

    private var goalPage: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundStyle(Theme.accent)

            Text("Cosa cerchi?")
                .font(.title.bold())

            Text("Scegli il tuo obiettivo principale.")
                .foregroundStyle(Theme.muted)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(goals, id: \.0) { goal, icon in
                    Button {
                        withAnimation(.spring) {
                            selectedGoal = goal
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: icon)
                                .font(.title3)
                            Text(goal)
                                .font(.caption.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(selectedGoal == goal ? AnyShapeStyle(Theme.accent) : AnyShapeStyle(Theme.card))
                        .foregroundStyle(selectedGoal == goal ? .white : Theme.text)
                        .clipShape(.rect(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(30)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }

    private var moodPage: some View {
        VStack(spacing: 24) {
            Image(systemName: "face.smiling")
                .font(.system(size: 60))
                .foregroundStyle(Theme.accent)

            Text("Come ti senti ora?")
                .font(.title.bold())

            Text("Questo mi aiuta a personalizzare la tua esperienza.")
                .foregroundStyle(Theme.muted)

            HStack(spacing: 16) {
                ForEach(["😊", "😐", "😢", "😡", "😴"], id: \.self) { emoji in
                    Button {
                        withAnimation(.spring) {
                            selectedMood = emoji
                        }
                    } label: {
                        Text(emoji)
                            .font(.system(size: 44))
                            .padding(12)
                            .background(selectedMood == emoji ? AnyShapeStyle(Theme.accent.opacity(0.2)) : AnyShapeStyle(Theme.card))
                            .clipShape(.circle)
                            .overlay(
                                selectedMood == emoji ?
                                Circle().stroke(Theme.accent, lineWidth: 2) : nil
                            )
                    }
                }
            }
        }
        .padding(30)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }

    private var finalPage: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 70))
                .foregroundStyle(Theme.accent)
                

            Text("Tutto pronto! 🎉")
                .font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: 12) {
                if !name.isEmpty {
                    Label("Nome: \(name)", systemImage: "person.fill")
                }
                if let goal = selectedGoal {
                    Label("Obiettivo: \(goal)", systemImage: "target")
                }
                if let mood = selectedMood {
                    Label("Umore: \(mood)", systemImage: "face.smiling")
                }
            }
            .font(.subheadline)
            .padding()
            .background(Theme.card)
            .clipShape(.rect(cornerRadius: 16))

            Text("Ora puoi iniziare il tuo percorso di benessere.\nParla con BenessereBot, traccia il tuo umore,\nesplora le funzioni.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.muted)

            Button {
                UserDefaults.standard.set(true, forKey: "hasSeenIntro")
                if !name.isEmpty {
                    UserDefaults.standard.set(name, forKey: "userName")
                }
                if let goal = selectedGoal {
                    UserDefaults.standard.set(goal, forKey: "userGoal")
                }
                withAnimation {
                    showIntro = false
                }
            } label: {
                Text("Inizia il percorso →")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accent)
                    .clipShape(.rect(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
        }
        .padding(30)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
}

#Preview {
    IntroView(showIntro: .constant(true))
}

