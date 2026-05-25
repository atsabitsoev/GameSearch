//
//  Team.swift
//  GameSearch
//

import Foundation

struct Team: Identifiable, Hashable, Sendable, Codable {
    let id: TeamId
    let name: String
    let slug: String
    let acronym: String?
    let location: String?
    let imageUrl: URL?
    let currentGame: Game?
    let players: [Player]?
    let modifiedAt: Date?
}
