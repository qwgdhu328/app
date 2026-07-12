import SwiftUI

struct WellnessScoreView: View {
    var score: Int
    var label: String

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(Theme.card, lineWidth: 6)
                    .frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: Double(score) / 100)
                    .stroke(scoreColor, style: .init(lineWidth: 6, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1), value: score)
                Text("\(score)").font(.callout.weight(.bold)).foregroundStyle(Theme.text)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Punteggio benessere").font(.caption).foregroundStyle(Theme.muted)
                Text(label).font(.subheadline.weight(.medium)).foregroundStyle(Theme.text)
            }
            Spacer()
        }
        .card()
    }

    private var scoreColor: Color {
        score >= 80 ? .green : score >= 50 ? .orange : .red
    }
}

func computeWellnessScore(moods: Int, streak: Int, sessions: Int, entries: Int) -> Int {
    let m = min(moods * 10, 30)
    let s = min(streak * 5, 30)
    let b = min(sessions * 15, 25)
    let j = min(entries * 10, 25)
    return min(m + s + b + j, 100)
}
