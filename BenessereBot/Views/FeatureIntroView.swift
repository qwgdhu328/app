import SwiftUI

struct FeatureIntroView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featureCards
                }
                .padding(20)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(AppBackground())
            .navigationTitle("Scopri l'App")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.accent)
            Text("Tutto ciò che puoi fare")
                .font(.title2.bold())
            Text("Esplora le funzioni di BenessereBot")
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Theme.card)
        .clipShape(.rect(cornerRadius: 20))
    }

    private var featureCards: some View {
        VStack(spacing: 16) {
            featureCard(
                icon: "brain.head.profile",
                title: "Psicologo AI",
                description: "Parla con BenessereBot, il tuo psicologo virtuale. Condividi pensieri ed emozioni in un ambiente sicuro e senza giudizio.",
                color: .blue
            )
            featureCard(
                icon: "person.2.fill",
                title: "Psicologi in città",
                description: "Quando la chat si fa complessa, trova psicologi professionisti nella tua città con un solo tocco.",
                color: .green
            )
            featureCard(
                icon: "face.smiling.fill",
                title: "Tracciamento umore",
                description: "Registra il tuo umore ogni giorno e segui il tuo percorso di benessere con statistiche personali.",
                color: .orange
            )
            featureCard(
                icon: "flame.fill",
                title: "Serie di obiettivi",
                description: "Mantieni la costanza con il conteggio dei giorni consecutivi. Ogni giorno conta!",
                color: .red
            )
            featureCard(
                icon: "quote.bubble.fill",
                title: "Affermazioni quotidiane",
                description: "Ricevi messaggi di ispirazione e affermazioni positive per iniziare bene la giornata.",
                color: .purple
            )
            featureCard(
                icon: "globe",
                title: "Spazio community",
                description: "Esplora gruppi di supporto, articoli sul benessere, eventi e sfide per crescere insieme.",
                color: .teal
            )
            featureCard(
                icon: "mic.fill",
                title: "Chat vocale",
                description: "Usa il microfono per parlare con BenessereBot. Il riconoscimento vocale trasforma la tua voce in testo.",
                color: .pink
            )
            featureCard(
                icon: "wind",
                title: "Respiro guidato",
                description: "Timer di respiro consapevole con supporto Dynamic Island. Respira con calma e ritrova il centro.",
                color: .teal
            )
        }
    }

    private func featureCard(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12))
                .clipShape(.circle)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    FeatureIntroView()
}

