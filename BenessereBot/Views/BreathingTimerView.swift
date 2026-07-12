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
                    .foregroundStyle(AppColors.breathingAccent)
                    .contentTransition(.numericText())
                Text("\(formattedTime(service.secondsLeft))")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            ProgressView(value: service.progress)
                .tint(AppColors.breathingAccent)
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
                            .background(AppColors.breathingAccent)
                            .clipShape(.capsule)
                    }
                }
            }
        }
        .padding(24)
        .background(Color(red: 0.12, green: 0.14, blue: 0.22))
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
                    .foregroundStyle(AppColors.textSecondary)
                Stepper("\(service.rounds)", value: $service.rounds, in: 1...10)
                    .foregroundStyle(AppColors.textPrimary)
            }
            Text("Durata: \(service.totalDuration / 60) min \(service.totalDuration % 60)s")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var animatedCircle: some View {
        ZStack {
            Circle()
                .stroke(AppColors.breathingAccent.opacity(0.15), lineWidth: 4)
                .frame(width: 100, height: 100)
            Circle()
                .trim(from: 0, to: service.progress)
                .stroke(AppColors.breathingAccent, style: .init(lineWidth: 4, lineCap: .round))
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: service.progress)
            Image(systemName: "wind")
                .font(.title)
                .foregroundStyle(AppColors.breathingAccent)
                .symbolEffect(.pulse, isActive: service.isActive)
        }
    }

    private func formattedTime(_ total: Int) -> String {
        let m = total / 60; let s = total % 60
        return "\(m):\(String(format: "%02d", s))"
    }
}
