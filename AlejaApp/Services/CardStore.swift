import Foundation
import SwiftUI
import WidgetKit

@MainActor
final class CardStore: ObservableObject {
    @Published private(set) var cards: [DailyCard] = []
    @Published private(set) var calendarDays: [CalendarDayContent] = []
    @Published private(set) var songs: [CatalogSong] = []

    private let storageKey = "aleja.dailyCards.v1"
    private let appGroup = "group.com.anhjs01.aleja"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        loadBundledContent()
        loadSavedCards()
        ensureCards(for: .now)
    }

    func cards(for date: Date) -> [DailyCard] {
        let key = DailyCard.key(for: date)
        let saved = cards.filter { $0.dayKey == key }.sorted { $0.slot.rawValue < $1.slot.rawValue }
        if !saved.isEmpty { return saved }
        return makeCards(for: date)
    }

    func update(_ card: DailyCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
        } else {
            cards.append(card)
        }
        save()
    }

    func ensureCards(for date: Date) {
        let key = DailyCard.key(for: date)
        let existingSlots = Set(cards.filter { $0.dayKey == key }.map(\.slot))
        let missing = makeCards(for: date).filter { !existingSlots.contains($0.slot) }
        guard !missing.isEmpty else { return }
        cards.append(contentsOf: missing)
        save()
    }

    func calendarDay(for date: Date) -> CalendarDayContent? {
        let key = DailyCard.key(for: date)
        return calendarDays.first { $0.fecha == key }
    }

    private func makeCards(for date: Date) -> [DailyCard] {
        let key = DailyCard.key(for: date)
        guard let source = calendarDays.first(where: { $0.fecha == key }) else {
            return DailyCard.starterCards(for: date)
        }

        let songURL: URL? = {
            if let url = source.cancionUrl.flatMap(URL.init(string:)) {
                return url
            }
            if let id = source.youtubeId, !id.isEmpty {
                return URL(string: "https://www.youtube.com/watch?v=\(id)")
            }
            var components = URLComponents(string: "https://www.youtube.com/results")
            components?.queryItems = [
                URLQueryItem(name: "search_query", value: "\(source.cancionTitulo) \(source.cancionArtista)")
            ]
            return components?.url
        }()

        return [
            DailyCard(dayKey: key, slot: .morning, message: source.buenosDias,
                      songTitle: source.cancionTitulo, songArtist: source.cancionArtista, songURL: songURL),
            DailyCard(dayKey: key, slot: .midday, message: source.middayMessage,
                      songTitle: source.cancionTitulo, songArtist: source.cancionArtista, songURL: songURL),
            DailyCard(dayKey: key, slot: .evening, message: source.buenasNoches,
                      songTitle: source.cancionTitulo, songArtist: source.cancionArtista, songURL: songURL)
        ]
    }

    private func loadBundledContent() {
        if let url = Bundle.main.url(forResource: "calendario-original", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? decoder.decode([CalendarDayContent].self, from: data) {
            calendarDays = decoded.sorted { $0.fecha < $1.fecha }
        }

        if let url = Bundle.main.url(forResource: "catalogo-canciones", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? decoder.decode([CatalogSong].self, from: data) {
            songs = decoded
        }
    }

    private func loadSavedCards() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? decoder.decode([DailyCard].self, from: data) else {
            cards = []
            return
        }
        cards = decoded
    }

    private func save() {
        guard let data = try? encoder.encode(cards) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)

        if let sharedDefaults = UserDefaults(suiteName: appGroup) {
            for card in cards {
                sharedDefaults.set(card.message, forKey: "widget.message.\(card.id)")
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
