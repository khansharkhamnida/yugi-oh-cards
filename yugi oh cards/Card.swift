//
//  Card.swift
//  yugi oh cards
//
//  Created by Shofia Ghazali on 19/10/26.
//

import Foundation
import UIKit

enum CardType: String, CaseIterable, Codable {
    case monster = "Monster"
    case spell = "Spell"
    case trap = "Trap"
}

enum CardAttribute: String, CaseIterable, Codable {
    case dark = "DARK"
    case divine = "DIVINE"
    case earth = "EARTH"
    case fire = "FIRE"
    case light = "LIGHT"
    case water = "WATER"
    case wind = "WIND"
}

enum SpellTrapProperty: String, CaseIterable, Codable {
    case normal = "Normal"
    case continuous = "Continuous"
    case counter = "Counter"     // Trap only
    case equip = "Equip"         // Spell only
    case field = "Field"         // Spell only
    case quickPlay = "Quick-Play" // Spell only
    case ritual = "Ritual"       // Spell only
}

enum MonsterType: String, Codable, CaseIterable {
    case aqua = "Aqua"
    case beast = "Beast"
    case beastWarrior = "Beast-Warrior"
    case cyberse = "Cyberse"
    case dinosaur = "Dinosaur"
    case dragon = "Dragon"
    case fairy = "Fairy"
    case fiend = "Fiend"
    case insect = "Insect"
    case machine = "Machine"
    case plant = "Plant"
    case psychic = "Psychic"
    case pyro = "Pyro"
    case reptile = "Reptile"
    case rock = "Rock"
    case spellcaster = "Spellcaster"
    case thunder = "Thunder"
    case warrior = "Warrior"
    case wingedBeast = "Winged Beast"
    case wyrm = "Wyrm"
    case zombie = "Zombie"
}

enum CardImageStore {

    static func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85)
        else { return nil }

        let filename = "\(UUID().uuidString).jpg"
        let url = directory.appendingPathComponent(filename)

        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            print("Failed to save image:", error)
            return nil
        }
    }

    static func load(_ name: String?) -> UIImage? {
        guard let name else { return nil }

        // First check uploaded images in Documents.
        let url = directory.appendingPathComponent(name)

        if let image = UIImage(contentsOfFile: url.path) {
            return image
        }

        // Otherwise, check Assets.xcassets.
        return UIImage(named: name)
    }

    private static var directory: URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
    }
}
