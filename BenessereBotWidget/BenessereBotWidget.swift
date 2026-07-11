import WidgetKit
import SwiftUI
import ActivityKit

struct BenessereBotWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.benesserebot.widget", provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.regularMaterial, for: .widget)
        }
        .configurationDisplayName("BenessereBot")
        .description("Parla con BenessereBot direttamente dalla schermata Home.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [SimpleEntry(date: Date())], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.title)
                .foregroundStyle(.tint)
            Text("Parla con\nBenessereBot")
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)
        }
    }
}

struct ReminderLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ReminderActivityAttributes.self) { context in
            LiveActivityView(context: context)
                .activityBackgroundTint(.blue.opacity(0.15))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    LiveActivityView(context: context)
                }
            } compactLeading: {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.tint)
            } compactTrailing: {
                Text("Ora")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tint)
            } minimal: {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.tint)
            }
            .keylineTint(.blue)
        }
    }
}

struct LiveActivityView: View {
    let context: ActivityViewContext<ReminderActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text("BenessereBot")
                    .font(.headline)
                Text(context.state.reminderMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
