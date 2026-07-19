import SwiftUI

struct BreathingTimerView: View {
    @ObservedObject var service: BreathingService

    var body: some View {
        VStack(spacing: 24) {
            if !service.isActive { pickersSection }

            ZStack {
                Circle()
                    .stroke(Theme.cardBorder, lineWidth: 5)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: service.progress)
                    .stroke(Theme.gradientAccent, style: .init(lineWidth: 5, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: service.progress)
                VStack(spacing: 4) {
                    Image(systemName: "wind")
                        .font(.title2)
                        .foregroundStyle(Theme.accent)
                        .symbolEffect(.pulse, isActive: service.isActive)
                    Text("\(service.roundsCompleted + 1)/\(service.rounds)")
                        .font(.caption2)
                        .foregroundStyle(Theme.muted)
                }
            }

            VStack(spacing: 6) {
                Text(service.phase)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Theme.accent)
                    .contentTransition(.numericText())
                Text(formattedTime(service.secondsLeft))
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.text)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }

            ProgressView(value: service.progress)
                .tint(Theme.accent)

            HStack(spacing: 20) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    service.stop()
                } label: {
                    Label("Stop", systemImage: "stop.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                        .padding(.horizontal, 28).padding(.vertical, 12)
                        .background(Theme.surface)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.cardBorder, lineWidth: 1))
                }

                if !service.isActive {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        service.start()
                    } label: {
                        Label("Avvia", systemImage: "play.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.text)
                            .padding(.horizontal, 28).padding(.vertical, 12)
                            .background(Theme.accent.opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1))
                    }
                }
            }
        }
        .padding(24)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Theme.cardBorder, lineWidth: 1))
        .padding(.horizontal, 20).padding(.bottom, 12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var pickersSection: some View {
        VStack(spacing: 12) {
            Picker("Pattern", selection: $service.pattern) {
                ForEach(BreathingPattern.allCases, id: \.self) { p in
                    Text(p.rawValue).tag(p)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Cicli:").foregroundStyle(Theme.muted)
                Stepper("\(service.rounds)", value: $service.rounds, in: 1...10)
                    .foregroundStyle(Theme.text)
            }

            Text("Durata: \(service.totalDuration / 60) min \(service.totalDuration % 60)s")
                .font(.caption).foregroundStyle(Theme.muted)
        }
    }

    private func formattedTime(_ total: Int) -> String {
        "\(total / 60):\(String(format: "%02d", total % 60))"
    }
}
