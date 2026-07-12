import SwiftUI

struct FeatureIntroView: View {
    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 20) {
                    featureCard(icon: "bubble.left.and.bubble.right.fill", title: "Chat AI", desc: "Parla con un assistente empatico 24/7")
                    featureCard(icon: "heart.fill", title: "Monitoraggio Umore", desc: "Traccia le tue emozioni ogni giorno")
                    featureCard(icon: "wind", title: "Respiro Guidato", desc: "Timer con Dynamic Island e pattern multipli")
                    featureCard(icon: "mic.fill", title: "Input Vocale", desc: "Dettatura supportata da SpeechKit")
                    featureCard(icon: "flame.fill", title: "Streak Giornaliero", desc: "Mantieni la costanza giorno dopo giorno")
                }
                .padding()
            }
            .navigationTitle("Funzioni")
        }
    }

    private func featureCard(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.breathing)
                .frame(width: 44, height: 44)
                .background(Theme.breathing.opacity(0.12))
                .clipShape(.circle)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(Theme.text)
                Text(desc).font(.subheadline).foregroundStyle(Theme.muted)
            }
            Spacer()
        }
        .card()
    }
}
