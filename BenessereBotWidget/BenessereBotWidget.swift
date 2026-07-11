import WidgetKit
import SwiftUI

@main
struct BenessereBotWidgetBundle: WidgetBundle {
    var body: some Widget {
        BenessereBotWidget()
    }
}

struct BenessereBotWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.benesserebot.widget", provider: Provider()) { entry in
            Text("BenessereBot").containerBackground(.regularMaterial, for: .widget)
        }
        .configurationDisplayName("BenessereBot")
        .description("Widget BenessereBot")
        .supportedFamilies([.systemSmall])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) { completion(SimpleEntry(date: Date())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [SimpleEntry(date: Date())], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry { let date: Date }
