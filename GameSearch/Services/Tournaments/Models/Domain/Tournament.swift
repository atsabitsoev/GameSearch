//
//  Tournament.swift
//  GameSearch
//

import Foundation

struct Tournament: Identifiable, Hashable, Sendable, Codable {
    let id: TournamentId
    let slug: String
    let name: String
    let tier: Tier?
    let game: Game
    let league: League
    let serie: Serie
    let beginAt: Date?
    let endAt: Date?
    let prizepool: Prizepool?
    let country: String?
    let region: String?
    let liveSupported: Bool
    let modifiedAt: Date?

    let matches: [Match]?
    let participants: [TournamentParticipant]?

    var displayTitle: String {
        "\(league.name) — \(serie.name) · \(name)"
    }

    var isLive: Bool {
        guard let begin = beginAt, let end = endAt else { return false }
        let now = Date()
        return begin <= now && now <= end
    }
}

struct Prizepool: Hashable, Sendable, Codable {
    let amount: Decimal
    let currency: String
}

struct TournamentParticipant: Hashable, Sendable, Codable, Identifiable {
    var id: TeamId { team.id }
    let team: Team
    let players: [Player]
}
