import SwiftUI
import WidgetKit

struct AlejaWidgetEntry: TimelineEntry {
    let date: Date
    let message: String
    let slotTitle: String
}

struct AlejaWidgetProvider: TimelineProvider {
    private let suiteName = "group.com.anhjs01.aleja"

    func placeholder(in context: Context) -> AlejaWidgetEntry {
        AlejaWidgetEntry(date: .now, message: "Un pequeño detalle para recordarte lo especial que eres.", slotTitle: "Una cartica para ti")
    }

    func getSnapshot(in context: Context, completion: @escaping (AlejaWidgetEntry) -> Void) {
        completion(makeEntry(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlejaWidgetEntry>) -> Void) {
        let entry = makeEntry(for: .now)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func makeEntry(for date: Date) -> AlejaWidgetEntry {
        let defaults = UserDefaults(suiteName: suiteName)
        let key = DailyCard.key(for: date)
        let hour = Calendar.current.component(.hour, from: date)
        let slot: CardSlot = hour < 12 ? .morning : (hour < 18 ? .midday : .evening)
        let cardKey = "\(key)-\(slot.rawValue)"
        let message = defaults?.string(forKey: "widget.message.\(cardKey)")
            ?? "Abre la app para leer tu cartica de hoy."
        return AlejaWidgetEntry(date: date, message: message, slotTitle: slot.title)
    }
}

struct AlejaWidgetView: View {
    let entry: AlejaWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Para Aleja", systemImage: "heart.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.blue)
            Text(entry.slotTitle)
                .font(.headline)
                .lineLimit(2)
            Text(entry.message)
                .font(.caption)
                .lineLimit(family == .accessoryRectangular ? 2 : 4)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Text("Toca para leer completa")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.blue)
        }
        .padding(4)
        .containerBackground(.background, for: .widget)
        .widgetURL(URL(string: "aleja://today"))
    }
}

@main
struct AlejaWidget: Widget {
    let kind = "AlejaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlejaWidgetProvider()) { entry in
            AlejaWidgetView(entry: entry)
        }
        .configurationDisplayName("Cartica para Aleja")
        .description("Un fragmento de tu cartica del día.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
