import Foundation
import UserNotifications
import Combine

@MainActor
class BreathingService: ObservableObject {
    @Published var isActive = false
    @Published var phase: String = ""
    @Published var secondsLeft = 0
    @Published var progress: Double = 0

    private let totalSeconds = 60
    private var timer: AnyCancellable?
    private var elapsed = 0

    func start() {
        elapsed = 0
        secondsLeft = totalSeconds
        progress = 0
        isActive = true
        phase = "Inspira..."
        runCycle()
    }

    func stop() {
        timer?.cancel()
        timer = nil
        isActive = false
        phase = ""
        secondsLeft = 0
        progress = 0
    }

    private func runCycle() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsed += 1
                self.secondsLeft = self.totalSeconds - self.elapsed
                self.progress = Double(self.elapsed) / Double(self.totalSeconds)

                let cycle = self.elapsed % 8
                if cycle < 4 {
                    self.phase = cycle == 0 ? "Inspira..." : "Inspira lentamente... 🌬️"
                } else {
                    self.phase = cycle == 4 ? "Espira..." : "Espira dolcemente... 🌿"
                }

                if self.elapsed >= self.totalSeconds {
                    self.complete()
                }
            }
    }

    private func complete() {
        stop()
        scheduleCompletionNotification()
    }

    private func scheduleCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Respiro completato! 🧘"
        content.body = "Hai completato 1 minuto di respiro consapevole."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "breathing-complete",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
