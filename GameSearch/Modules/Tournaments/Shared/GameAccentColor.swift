//
//  GameAccentColor.swift
//  GameSearch
//
//  Helper that maps `Game` to the brand color of that game.
//  Centralises the lookup so views never branch on `Game` themselves.
//

import SwiftUI

enum GameAccentColor {
    static func color(for game: Game) -> Color {
        switch game {
        case .cs2: EAColor.csColor
        case .dota2: EAColor.dotaColor
        }
    }

    static func iconName(for game: Game) -> String {
        game.iconName
    }
}
