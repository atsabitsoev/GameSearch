//
//  ArticlesFilter.swift
//  GameSearch
//
//  Created by Codex on 17.04.2026.
//

enum ArticlesFilter: String, CaseIterable, Identifiable {
    case all
    case cs2
    case dota2
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "Все"
        case .cs2: return "CS2"
        case .dota2: return "Dota 2"
        case .other: return "Другое"
        }
    }
}
