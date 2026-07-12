import Foundation
import UserNotifications
import Combine
import ActivityKit

@MainActor
class BreathingService: ObservableObject {
    @Published var isActive = false
    @Published var phase: String = ""
    @Published var secondsLeft = 0
    @Published var progress: Double = 0

    private let totalSeconds = 60
    private var timer: AnyCancellable?
    private var elapsed = 0
    private var activity: Activity<BreathingActivityAttributes>?

    func start() {
        elapsed = 0
        secondsLeft = totalSeconds
        progress = 0
        isActive = true
        phase = "Inspira..."
        startLiveActivity()
        runCycle()
    }

    func stop() {
        timer?.cancel()
        timer = nil
        isActive = false
        endLiveActivity()
        activity = nil
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
                    self.phase = cycle == 0 ? "Inspira..." : "Inspira lentamente..."
                } else {
                    self.phase = cycle == 4 ? "Espira..." : "Espira dolcemente..."
                }

                self.updateLiveActivity()

                if self.elapsed >= self.totalSeconds {
                    self.complete()
                }
            }
    }

    private func complete() {
        endLiveActivity(finalState: true)
        activity = nil
        scheduleCompletionNotification()
        isActive = false
    }

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = BreathingActivityAttributes(startedAt: Date())
        let state = BreathingActivityAttributes.ContentState(
            phase: phase,
            secondsLeft: secondsLeft,
            progress: progress
        )
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil)
            )
        } catch {
            print("Activity start error: \(error)")
        }
    }

    private func updateLiveActivity() {
        Task {
            let state = BreathingActivityAttributes.ContentState(
                phase: phase,
                secondsLeft: secondsLeft,
                progress: progress
            )
            await activity?.update(.init(state: state, staleDate: nil))
        }
    }

    private func endLiveActivity(finalState: Bool = false) {
        Task {
            let state = BreathingActivityAttributes.ContentState(
                phase: finalState ? "Completato! 🧘" : "Terminato",
                secondsLeft: 0,
                progress: finalState ? 1.0 : progress
            )
            await activity?.end(.init(state: state, staleDate: nil), dismissalPolicy: .immediate)
        }
    }

    private func scheduleCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Respiro completato!"
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
