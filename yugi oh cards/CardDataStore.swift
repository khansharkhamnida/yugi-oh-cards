//
//  CardDataStore.swift
//  yugi oh cards
//
//  Created by Dian Maisara on 23/10/26.
//

// MARK: Persistence Layer & MVC
// MARK: 1. Shared static singleton which stores the cards
import Foundation

class YugiohCardDataStore {
    static let shared = YugiohCardDataStore() // 1. singleton
    
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
                property: .normal
            )
        ]

    private init() {
        seedIfNeeded()
    }

    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return documentsPath.appendingPathComponent("cards.json")
    }
    
    private func seedIfNeeded() {
        guard !FileManager.default.fileExists(atPath: fileURL.path) else { return }
        saveYugiohCards(Self.initialCards)
    }

    func loadYugiohCards() -> [YugiohCard] {
        guard let data = try? Data(contentsOf: fileURL),
              let cards = try? JSONDecoder().decode([YugiohCard].self, from: data) else {
            return []
        }
        return cards
    }

    func saveYugiohCards(_ cards: [YugiohCard]) {
        // 2. try? without error handling
        guard let data = try? JSONEncoder().encode(cards) else { return }
        try? data.write(to: fileURL)
    }
    
    // MARK: 2. Implement the following functions to offload to the store
    func addYugiohCard(_ card: YugiohCard) {
        var cards = loadYugiohCards()
        cards.append(card)
        saveYugiohCards(cards)
    }
    
    func updateYugiohCard(_ card: YugiohCard) {
        var cards = loadYugiohCards()
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index] = card
        saveYugiohCards(cards)
    }
    
    func deleteYugiohCard(_ card: YugiohCard) {
        var cards = loadYugiohCards()
        cards.removeAll { $0.id == card.id }
        saveYugiohCards(cards)
    }
    
    func deleteYugiohCard(at index: Int) {
        var cards = loadYugiohCards()
        cards.remove(at: index)
        saveYugiohCards(cards)
    }
}
