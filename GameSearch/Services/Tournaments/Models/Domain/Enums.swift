//
//  Enums.swift
//  GameSearch
//
//  Domain enums and ID type aliases for the Tournaments module.
//

import Foundation

// MARK: - ID aliases

typealias TournamentId = Int
typealias MatchId = Int
typealias TeamId = Int
typealias PlayerId = Int
typealias LeagueId = Int
typealias SerieId = Int
typealias VideogameId = Int

// MARK: - Game

enum Game: String, Hashable, Sendable, CaseIterable, Codable {
    case cs2
    case dota2

    var displayName: String {
        switch self {
        case .cs2: "CS2"
        case .dota2: "Dota 2"
        }
    }

    var pandaScorePrefix: String {
        switch self {
        case .cs2: "csgo"
        case .dota2: "dota2"
        }
    }

    var iconName: String {
        switch self {
        case .cs2: "cs"
        case .dota2: "dota2"
        }
    }

    init?(pandaScoreSlug: String?) {
        switch pandaScoreSlug {
        case "cs-go", "csgo", "cs2": self = .cs2
        case "dota-2", "dota2": self = .dota2
        default: return nil
        }
    }

    init?(pandaScoreId: VideogameId?) {
        switch pandaScoreId {
        case 3: self = .cs2
        case 4: self = .dota2
        default: return nil
        }
    }
}

// MARK: - Tier

enum Tier: String, Hashable, Sendable, CaseIterable, Codable, Comparable {
    case s, a, b, c, d

    var displayName: String { rawValue.uppercased() }

    /// Lower rank = higher prestige. Powers `Comparable`, which is used by
    /// list ordering (`TournamentsListViewModel.applyLoadedState`) to put
    /// S-tier majors above amateur events. PandaScore's own `sort=tier`
    /// would sort alphabetically (a < b < … < s) and put S last, so we
    /// always sort tier on the client.
    var rank: Int {
        switch self {
        case .s: 0
        case .a: 1
        case .b: 2
        case .c: 3
        case .d: 4
        }
    }

    static func < (lhs: Tier, rhs: Tier) -> Bool {
        lhs.rank < rhs.rank
    }
}

// MARK: - TournamentSegment

enum TournamentSegment: String, Hashable, Sendable, CaseIterable, Codable {
    case running
    case upcoming
    case past

    var pandaScorePath: String { rawValue }
}

// MARK: - MatchStatus

enum MatchStatus: String, Hashable, Sendable, Codable {
    case notStarted = "not_started"
    case running
    case finished
    case canceled
    case postponed

    var isLive: Bool { self == .running }
    var isOver: Bool { self == .finished || self == .canceled }
}

// MARK: - MatchType

enum MatchType: String, Hashable, Sendable, Codable {
    case bestOf = "best_of"
    case allGamesPlayed = "all_games_played"
    case ftw = "ftw"
    case singleGame = "single_game"
}

// MARK: - StreamPlatform

enum StreamPlatform: Hashable, Sendable, Codable {
    case twitch(channel: String)
    case youtube(videoId: String?)
    case other(url: URL)
}

// MARK: - WinnerType

enum WinnerType: String, Hashable, Sendable, Codable {
    case team = "Team"
    case player = "Player"
}
