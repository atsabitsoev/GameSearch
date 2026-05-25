//
//  PandaScoreFixtures.swift
//  GameSearchTests
//

import Foundation
import XCTest
@testable import GameSearch

enum PandaScoreFixtures {

    static func data(named name: String, in bundleClass: AnyClass) throws -> Data {
        let bundle = Bundle(for: bundleClass)
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw NSError(
                domain: "PandaScoreFixtures",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing fixture \(name).json in test bundle"]
            )
        }
        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(
        _ type: T.Type,
        named name: String,
        in bundleClass: AnyClass
    ) throws -> T {
        let data = try data(named: name, in: bundleClass)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - Domain fixtures (for tests that don't care about JSON shape)

extension Tournament {
    static func fixture(
        id: TournamentId = 1,
        slug: String = "test-tournament",
        name: String = "Group Stage",
        tier: Tier? = .s,
        game: Game = .cs2,
        beginAt: Date? = Date(),
        endAt: Date? = Date().addingTimeInterval(86400 * 10)
    ) -> Tournament {
        Tournament(
            id: id,
            slug: slug,
            name: name,
            tier: tier,
            game: game,
            league: League(id: 1, name: "Test League", slug: "test-league", imageUrl: nil),
            serie: Serie(id: 1, name: "Test Serie", fullName: nil, year: 2026, season: nil),
            beginAt: beginAt,
            endAt: endAt,
            prizepool: nil,
            country: "DK",
            region: "EUROPE",
            liveSupported: false,
            modifiedAt: nil,
            matches: nil,
            participants: nil
        )
    }
}

extension Match {
    static func fixture(
        id: MatchId = 1001,
        status: MatchStatus = .running,
        game: Game = .cs2,
        tournamentId: TournamentId = 1,
        leagueId: LeagueId = 1
    ) -> Match {
        Match(
            id: id,
            name: "Fixture Match",
            status: status,
            matchType: .bestOf,
            numberOfGames: 3,
            scheduledAt: Date(),
            beginAt: Date(),
            endAt: nil,
            draw: false,
            forfeit: false,
            tournamentId: tournamentId,
            leagueId: leagueId,
            game: game,
            opponents: [],
            results: [],
            games: [],
            streams: [],
            winnerId: nil
        )
    }
}

extension Team {
    static func fixture(
        id: TeamId = 411,
        name: String = "FaZe Clan"
    ) -> Team {
        Team(
            id: id,
            name: name,
            slug: name.lowercased().replacingOccurrences(of: " ", with: "-"),
            acronym: nil,
            location: nil,
            imageUrl: nil,
            currentGame: .cs2,
            players: nil,
            modifiedAt: nil
        )
    }
}
