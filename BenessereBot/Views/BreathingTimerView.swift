import SwiftUI

struct BreathingTimerView: View {
    @ObservedObject var service: BreathingService

    var body: some View {
        VStack(spacing: 24) {
            if !service.isActive {
                pickersSection
            }
            animatedCircle
            VStack(spacing: 6) {
                Text(service.phase)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Theme.breathing)
                    .contentTransition(.numericText())
                Text("\(formattedTime(service.secondsLeft))")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.text)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            ProgressView(value: service.progress)
                .tint(Theme.breathing)
            HStack(spacing: 20) {
                Button { service.stop() } label: {
                    Label("Stop", systemImage: "stop.circle.fill")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.7))
                        .clipShape(.capsule)
                }
                if !service.isActive {
                    Button { service.start() } label: {
                        Label("Avvia", systemImage: "play.circle.fill")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(Theme.breathing)
                            .clipShape(.capsule)
                    }
                }
            }
        }
        .padding(24)
        .background(Theme.card)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.3), radius: 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
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
                Text("Cicli:")
                    .foregroundStyle(Theme.muted)
                Stepper("\(service.rounds)", value: $service.rounds, in: 1...10)
                    .foregroundStyle(Theme.text)
            }
            Text("Durata: \(service.totalDuration / 60) min \(service.totalDuration % 60)s")
                .font(.caption)
                .foregroundStyle(Theme.muted)
        }
    }

    private var animatedCircle: some View {
        ZStack {
            Circle()
                .stroke(Theme.breathing.opacity(0.15), lineWidth: 4)
                .frame(width: 100, height: 100)
            Circle()
                .trim(from: 0, to: service.progress)
                .stroke(Theme.breathing, style: .init(lineWidth: 4, lineCap: .round))
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: service.progress)
            Image(systemName: "wind")
                .font(.title)
                .foregroundStyle(Theme.breathing)
                .symbolEffect(.pulse, isActive: service.isActive)
        }
    }

    private func formattedTime(_ total: Int) -> String {
        let m = total / 60; let s = total % 60
        return "\(m):\(String(format: "%02d", s))"
    }
}
