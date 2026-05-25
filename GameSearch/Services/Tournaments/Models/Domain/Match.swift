//
//  Match.swift
//  GameSearch
//

import Foundation

struct Match: Identifiable, Hashable, Sendable, Codable {
    let id: MatchId
    let name: String
    let status: MatchStatus
    let matchType: MatchType
    let numberOfGames: Int
    let scheduledAt: Date?
    let beginAt: Date?
    let endAt: Date?
    let draw: Bool
    let forfeit: Bool
    let tournamentId: TournamentId
    let leagueId: LeagueId
    let game: Game
    let opponents: [Opponent]
    let results: [MatchResult]
    let games: [PlayedGame]
    let streams: [Stream]
    let winnerId: TeamId?

    var isLive: Bool { status.isLive }
    var isOver: Bool { status.isOver }
    var winner: Team? {
        guard let winnerId else { return nil }
        return opponents.first { $0.team.id == winnerId }?.team
    }
}

extension Match {

    struct Opponent: Hashable, Sendable, Codable {
        let team: Team
    }

    struct MatchResult: Hashable, Sendable, Codable {
        let teamId: TeamId
        let score: Int
    }

    struct PlayedGame: Identifiable, Hashable, Sendable, Codable {
        let id: Int
        let position: Int
        let status: MatchStatus
        let mapName: String?
        let winnerId: TeamId?
        let beginAt: Date?
        let endAt: Date?
        let length: TimeInterval?
        let videoUrl: URL?
    }
}
