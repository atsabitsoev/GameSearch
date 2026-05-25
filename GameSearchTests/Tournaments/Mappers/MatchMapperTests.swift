//
//  MatchMapperTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class MatchMapperTests: XCTestCase {

    func test_map_runningMatch_mapsAllFields() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScoreMatchDTO.self,
            named: "match_running",
            in: Self.self
        )

        let match = try XCTUnwrap(MatchMapper.map(dto))

        XCTAssertEqual(match.id, 1_071_234)
        XCTAssertEqual(match.name, "FaZe vs NaVi")
        XCTAssertEqual(match.status, .running)
        XCTAssertEqual(match.matchType, .bestOf)
        XCTAssertEqual(match.numberOfGames, 5)
        XCTAssertEqual(match.game, .cs2)
        XCTAssertEqual(match.tournamentId, 13420)
        XCTAssertEqual(match.leagueId, 4501)
        XCTAssertTrue(match.isLive)
        XCTAssertFalse(match.isOver)
    }

    func test_map_opponents_mapsTwoTeams() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScoreMatchDTO.self,
            named: "match_running",
            in: Self.self
        )

        let match = try XCTUnwrap(MatchMapper.map(dto))

        XCTAssertEqual(match.opponents.count, 2)
        XCTAssertEqual(match.opponents.map(\.team.id).sorted(), [411, 412])
    }

    func test_map_results_mapsScores() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScoreMatchDTO.self,
            named: "match_running",
            in: Self.self
        )

        let match = try XCTUnwrap(MatchMapper.map(dto))

        XCTAssertEqual(match.results.count, 2)
        XCTAssertEqual(match.results.first(where: { $0.teamId == 411 })?.score, 1)
        XCTAssertEqual(match.results.first(where: { $0.teamId == 412 })?.score, 0)
    }

    func test_map_games_extractsMapName() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScoreMatchDTO.self,
            named: "match_running",
            in: Self.self
        )

        let match = try XCTUnwrap(MatchMapper.map(dto))

        XCTAssertEqual(match.games.count, 1)
        XCTAssertEqual(match.games.first?.mapName, "Mirage")
        XCTAssertEqual(match.games.first?.winnerId, 411)
    }

    func test_map_streams_includesTwitchAndYouTube() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScoreMatchDTO.self,
            named: "match_running",
            in: Self.self
        )

        let match = try XCTUnwrap(MatchMapper.map(dto))

        XCTAssertEqual(match.streams.count, 2)
        XCTAssertTrue(match.streams.contains { stream in
            if case .twitch(let channel) = stream.platform { return channel == "maincast" }
            return false
        })
        XCTAssertTrue(match.streams.contains { stream in
            if case .youtube(let videoId) = stream.platform { return videoId == "abc123" }
            return false
        })
    }

    func test_map_missingTournamentId_returnsNil() throws {
        let json = """
        {
            "id": 1,
            "name": "M",
            "status": "running",
            "league_id": 4501,
            "videogame": { "id": 3, "name": "CS-GO", "slug": "cs-go" }
        }
        """.data(using: .utf8)!
        let decoder = makeDecoder()
        let dto = try decoder.decode(PandaScoreMatchDTO.self, from: json)

        XCTAssertNil(MatchMapper.map(dto))
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
