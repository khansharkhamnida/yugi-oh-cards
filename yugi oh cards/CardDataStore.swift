import Foundation

class YugiohCardDataStore {
    static let shared = YugiohCardDataStore()

    private static let initialCards: [YugiohCard] = [
        YugiohCard(
            name: "Dark Magician",
            cardType: .monster,
            description: "The ultimate wizard in terms of attack and defense.",
            cardNumber: "LOB-005",
            imageURLString: "dark-magician",
            attribute: .dark,
            level: 7,
            monsterType: .aqua,
            atk: 2500,
            def: 2100
        ),
        YugiohCard(
            name: "Blue-Eyes White Dragon",
            cardType: .monster,
            description: "This legendary dragon is a powerful engine of destruction.",
            cardNumber: "LOB-001",
            imageURLString: "BlueEyes",
            attribute: .light,
            level: 8,
            monsterType: .dragon,
            atk: 3000,
            def: 2500
        ),
        YugiohCard(
            name: "Monster Reborn",
            cardType: .spell,
            description: "Special Summon 1 monster from either GY.",
            cardNumber: "LOB-118",
            imageURLString: "MonsterReborn",
            property: .normal
        )
    ]

    private var cache: [YugiohCard]?

    // CHANGED: no longer throws, handles the error inside
    private init() {
        do {
            try seedIfNeeded()
        } catch {
            print("Seeding failed:", error)
        }
    }

    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return documentsPath.appendingPathComponent("cards.json")
    }

    private func seedIfNeeded() throws {
        guard !FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try saveYugiohCards(Self.initialCards)
    }

    func loadYugiohCards() -> [YugiohCard] {
        if let cache { return cache }
        guard let data = try? Data(contentsOf: fileURL),
              let cards = try? JSONDecoder().decode([YugiohCard].self, from: data) else {
            return []   // not cached, so the next call retries
        }
        cache = cards
        return cards
    }

    func saveYugiohCards(_ cards: [YugiohCard]) throws {
        let data = try JSONEncoder().encode(cards)       // no more silent try?
        try data.write(to: fileURL, options: .atomic)
        cache = cards
    }

    func addYugiohCard(_ card: YugiohCard) throws {
        var cards = loadYugiohCards()
        cards.append(card)
        try saveYugiohCards(cards)
    }

    func updateYugiohCard(_ card: YugiohCard) throws {
        var cards = loadYugiohCards()
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index] = card
        try saveYugiohCards(cards)
    }

    func deleteYugiohCard(_ card: YugiohCard) throws {
        var cards = loadYugiohCards()
        cards.removeAll { $0.id == card.id }
        try saveYugiohCards(cards)
    }

    func deleteYugiohCard(at index: Int) throws {
        var cards = loadYugiohCards()
        cards.remove(at: index)
        try saveYugiohCards(cards)
    }
}
