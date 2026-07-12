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
        .background(Theme.surface).background(Theme.glassGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private var featureCards: some View {
        VStack(spacing: 16) {
            featureCard(icon: "brain.head.profile", title: "Psicologo AI", description: "Parla con BenessereBot, il tuo psicologo virtuale. Condividi pensieri ed emozioni in un ambiente sicuro e senza giudizio.")
            featureCard(icon: "person.2.fill", title: "Psicologi in città", description: "Quando la chat si fa complessa, trova psicologi professionisti nella tua città con un solo tocco.")
            featureCard(icon: "face.smiling.fill", title: "Tracciamento umore", description: "Registra il tuo umore ogni giorno e segui il tuo percorso di benessere con statistiche personali.")
            featureCard(icon: "flame.fill", title: "Serie di obiettivi", description: "Mantieni la costanza con il conteggio dei giorni consecutivi. Ogni giorno conta!")
            featureCard(icon: "quote.bubble.fill", title: "Affermazioni quotidiane", description: "Ricevi messaggi di ispirazione e affermazioni positive per iniziare bene la giornata.")
            featureCard(icon: "globe", title: "Spazio community", description: "Esplora gruppi di supporto, articoli sul benessere, eventi e sfide per crescere insieme.")
            featureCard(icon: "mic.fill", title: "Chat vocale", description: "Usa il microfono per parlare con BenessereBot. Il riconoscimento vocale trasforma la tua voce in testo.")
            featureCard(icon: "wind", title: "Respiro guidato", description: "Timer di respiro consapevole con supporto Dynamic Island. Respira con calma e ritrova il centro.")
        }
    }

    private func featureCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.accent)
                .frame(width: 48, height: 48)
                .background(Theme.accent.opacity(0.12))
                .clipShape(.circle)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(Theme.text)
                Text(description).font(.subheadline).foregroundStyle(Theme.muted).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.surface).background(Theme.glassGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
    }
}

#Preview {
    FeatureIntroView()
}

