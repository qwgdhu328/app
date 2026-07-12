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
                    VStack(alignment: .leading, spacing: 2) {
                        Label(context.state.phase, systemImage: "wind")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.teal)
                        Text(context.attributes.pattern)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.secondsLeft)s")
                        .font(.title.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                        .tint(.teal)
                }
            } compactLeading: {
                Image(systemName: "wind")
                    .foregroundStyle(.teal)
                    .symbolEffect(.pulse)
            } compactTrailing: {
                Text("\(context.state.secondsLeft)s")
                    .font(.caption2.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
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
                Text(context.attributes.pattern)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(context.state.phase)
                    .font(.headline)
                    .foregroundStyle(.white)
                ProgressView(value: context.state.progress)
                    .tint(.teal)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("\(context.state.secondsLeft)s")
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text("\(context.attributes.totalMinutes) min")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .activityBackgroundTint(Color(red: 0.08, green: 0.09, blue: 0.15))
        .activitySystemActionForegroundColor(.teal)
    }
}
