//
//  Favorite.swift
//  GameSearch
//
//  Used in Phase 2. Defined here for forward-compat across services.
//

import Foundation

struct Favorite: Hashable, Sendable, Codable {
    enum Kind: String, Codable, Hashable, Sendable {
        case team
        case tournament
        case player
    }

    let kind: Kind
    let entityId: Int
    let displayName: String
    let imageUrl: URL?
    let game: Game?
    let addedAt: Date
}
