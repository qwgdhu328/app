import ActivityKit
import WidgetKit
import SwiftUI

struct BreathingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BreathingActivityAttributes.self) { context in
            BreathingLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.phase, systemImage: "wind")
                        .font(.headline)
                        .foregroundStyle(.teal)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.secondsLeft)s")
                        .font(.title2.weight(.bold))
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                        .tint(.teal)
                }
            } compactLeading: {
                Image(systemName: "wind")
                    .foregroundStyle(.teal)
            } compactTrailing: {
                Text("\(context.state.secondsLeft)s")
                    .font(.caption2.weight(.bold))
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "wind")
                    .foregroundStyle(.teal)
            }
        }
    }
}

private struct BreathingLockScreenView: View {
    let context: ActivityViewContext<BreathingActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "wind")
                .font(.title)
                .foregroundStyle(.teal)
                .symbolEffect(.pulse)

            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.phase)
                    .font(.headline)
                ProgressView(value: context.state.progress)
                    .tint(.teal)
            }

            Text("\(context.state.secondsLeft)s")
                .font(.title2.weight(.bold))
                .monospacedDigit()
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.2))
        .activitySystemActionForegroundColor(.teal)
    }
}
