//
//  CardModel.swift
//  yugi oh cards
//
//  Created by Shofia Ghazali on 19/10/26.
//
import Foundation

struct YugiohCard: Identifiable, Codable {
    // CRUD & Identity
    let id: UUID                  // Required for SwiftUI Lists
    var name: String
    var cardType: CardType        // Monster, Spell, or Trap
    var description: String       // Card text / effect
    var cardNumber: String        // e.g., "LOB-001" (Useful for unique identification)
    var imageURLString: String?   // URL to fetch artwork (or local asset name)
    
    // Monster Specifics (Optional)
    var attribute: CardAttribute? // e.g., LIGHT, DARK
    var level: Int?               // 1 to 12 (Stars)
    var monsterType: MonsterType?      // e.g., "Dragon / Normal" or "Spellcaster / Effect"
    var atk: Int?                 // Use Int? (or a String if you want to support "?" ATK)
    var def: Int?                 // Monster Defense
    
    // Spell / Trap Specifics (Optional)
    var property: SpellTrapProperty? // e.g., Continuous, Quick-Play
    
    // Initializer with default values for easy CRUD creation
    init(
        id: UUID = UUID(),
        name: String = "",
        cardType: CardType = .monster,
        description: String = "",
        cardNumber: String = "",
        imageURLString: String? = nil,
        attribute: CardAttribute? = nil,
        level: Int? = nil,
        monsterType: MonsterType? = nil,
        atk: Int? = nil,
        def: Int? = nil,
        property: SpellTrapProperty? = nil
    ) { 
        self.id = id
        self.name = name
        self.cardType = cardType
        self.description = description
        self.cardNumber = cardNumber
        self.imageURLString = imageURLString
        self.attribute = attribute
        self.level = level
        self.monsterType = monsterType
        self.atk = atk
        self.def = def
        self.property = property
    }
}
