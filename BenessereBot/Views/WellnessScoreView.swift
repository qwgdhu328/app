import SwiftUI

struct WellnessScoreView: View {
    var score: Int
    var label: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(Theme.cardBorder, lineWidth: 5).frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: Double(score) / 100)
                    .stroke(Theme.gradientAccent, style: .init(lineWidth: 5, lineCap: .round))
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
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardBorder, lineWidth: 1))
    }
}
