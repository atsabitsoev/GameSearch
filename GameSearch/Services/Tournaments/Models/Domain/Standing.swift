//
//  Standing.swift
//  GameSearch
//

import Foundation

struct Standing: Hashable, Sendable, Codable, Identifiable {
    var id: TeamId { team.id }
    let team: Team
    let rank: Int
    let wins: Int
    let losses: Int
    let ties: Int?
    let points: Int?
}
