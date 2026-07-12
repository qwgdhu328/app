import SwiftUI

struct WellnessScoreView: View {
    var score: Int
    var label: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(Theme.cardBorder, lineWidth: 6).frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: Double(score) / 100)
                    .stroke(scoreColor, style: .init(lineWidth: 6, lineCap: .round))
                    .frame(width: 56, height: 56).rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1), value: score)
                Text("\(score)").font(.callout.weight(.bold)).foregroundStyle(Theme.text)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Punteggio benessere").font(.caption).foregroundStyle(Theme.muted)
                Text(label).font(.subheadline.weight(.medium)).foregroundStyle(Theme.text)
            }
            Spacer()
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }

    private var scoreColor: Color { score >= 80 ? Theme.accent : score >= 50 ? Theme.accentSecondary : .red.opacity(0.7) }
}
