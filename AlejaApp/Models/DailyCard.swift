import Foundation

enum CardSlot: Int, CaseIterable, Codable, Identifiable {
    case morning = 0
    case midday = 1
    case evening = 2

    var id: Int { rawValue }

    var timeLabel: String {
        switch self {
        case .morning: return "06:00"
        case .midday: return "12:00"
        case .evening: return "18:00"
        }
    }

    var title: String {
        switch self {
        case .morning: return "Una cartica para empezar"
        case .midday: return "Una pausa para ti"
        case .evening: return "Una cartica para cerrar el día"
        }
    }

    var symbol: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .midday: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        }
    }
}

struct DailyCard: Identifiable, Codable, Hashable {
    var id: String { "\(dayKey)-\(slot.rawValue)" }
    let dayKey: String
    let slot: CardSlot
    var message: String
    var songTitle: String?
    var songArtist: String?
    var songURL: URL?

    var date: Date {
        Self.date(from: dayKey) ?? .now
    }

    static func key(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 2000,
                      components.month ?? 1, components.day ?? 1)
    }

    private static func date(from key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    static func starterCards(for date: Date) -> [DailyCard] {
        let key = key(for: date)
        return CardSlot.allCases.map { slot in
            DailyCard(
                dayKey: key,
                slot: slot,
                message: "Esta cartica está lista para personalizar. Aquí irá el mensaje especial de este momento del día.",
                songTitle: nil,
                songArtist: nil,
                songURL: nil
            )
        }
    }
}
