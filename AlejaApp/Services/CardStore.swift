import Foundation
import SwiftUI

@MainActor
final class CardStore: ObservableObject {
    @Published private(set) var cards: [DailyCard] = []

    private let storageKey = "aleja.dailyCards.v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        load()
        ensureCards(for: .now)
    }

    func cards(for date: Date) -> [DailyCard] {
        let key = DailyCard.key(for: date)
        let saved = cards.filter { $0.dayKey == key }.sorted { $0.slot.rawValue < $1.slot.rawValue }
        return saved.isEmpty ? DailyCard.starterCards(for: date) : saved
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
        let missing = DailyCard.starterCards(for: date).filter { !existingSlots.contains($0.slot) }
        guard !missing.isEmpty else { return }
        cards.append(contentsOf: missing)
        save()
    }

    private func load() {
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
    }
}
