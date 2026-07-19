import Foundation
import UserNotifications
import Combine
import ActivityKit
import UIKit

enum BreathingPattern: String, CaseIterable {
    case simple = "Semplice"
    case box = "Respiro Quadrato"
    case fourSevenEight = "4-7-8"

    var phases: [(String, Int)] {
        switch self {
        case .simple:
            return [("Inspira... 🌬️", 4), ("Espira... 🌿", 4)]
        case .box:
            return [("Inspira... 🌬️", 4), ("Trattieni... 🔵", 4), ("Espira... 🌿", 4), ("Attendi... ⏸️", 4)]
        case .fourSevenEight:
            return [("Inspira... 🌬️", 4), ("Trattieni... 🔵", 7), ("Espira... 🌿", 8)]
        }
    }

    var totalSeconds: Int {
        phases.map(\.1).reduce(0, +)
    }
}

@MainActor
class BreathingService: ObservableObject {
    @Published var isActive = false
    @Published var phase: String = ""
    @Published var secondsLeft = 0
    @Published var progress: Double = 0
    @Published var pattern: BreathingPattern = .simple
    @Published var rounds: Int = 3
    var totalDuration: Int { pattern.totalSeconds * rounds }

    private var timer: AnyCancellable?
    private var elapsed = 0
    private var currentPhaseIndex = 0
    private var phaseElapsed = 0
    @Published private(set) var roundsCompleted = 0
    private var activity: Activity<BreathingActivityAttributes>?

    func start() {
        elapsed = 0
        currentPhaseIndex = 0
        phaseElapsed = 0
        roundsCompleted = 0
        secondsLeft = totalDuration
        progress = 0
        isActive = true
        phase = currentPhase.label
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

    private var currentPhase: (label: String, duration: Int) {
        let p = pattern.phases
        return p[currentPhaseIndex % p.count]
    }

    private func runCycle() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsed += 1
                self.phaseElapsed += 1
                self.secondsLeft = self.totalDuration - self.elapsed
                self.progress = Double(self.elapsed) / Double(self.totalDuration)

                if self.phaseElapsed >= self.currentPhase.duration {
                    self.phaseElapsed = 0
                    self.currentPhaseIndex += 1
                    if self.currentPhaseIndex % self.pattern.phases.count == 0 {
                        self.roundsCompleted += 1
                        if self.roundsCompleted >= self.rounds {
                            self.complete()
                            return
                        }
                    }
                    self.phase = self.currentPhase.label
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
                self.updateLiveActivity()
            }
    }

    private func complete() {
        endLiveActivity(finalState: true)
        activity = nil
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        scheduleCompletionNotification()
        isActive = false
    }

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attrs = BreathingActivityAttributes(startedAt: Date(), pattern: pattern.rawValue, totalMinutes: totalDuration / 60)
        let state = BreathingActivityAttributes.ContentState(phase: phase, secondsLeft: secondsLeft, progress: progress)
        do {
            activity = try Activity.request(attributes: attrs, content: .init(state: state, staleDate: nil))
        } catch {
            
        }
    }

    private func updateLiveActivity() {
        Task {
            let state = BreathingActivityAttributes.ContentState(phase: phase, secondsLeft: secondsLeft, progress: progress)
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
        content.body = "Hai completato \(rounds) cicli di \(pattern.rawValue.lowercased())."
        content.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}
