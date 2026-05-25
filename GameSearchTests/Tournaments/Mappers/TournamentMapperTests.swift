//
//  TournamentMapperTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class TournamentMapperTests: XCTestCase {

    func test_map_runningTournament_mapsAllFields() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScoreTournamentDTO.self,
            named: "tournament_running_cs2",
            in: Self.self
        )

        let tournament = try XCTUnwrap(TournamentMapper.map(dto))

        XCTAssertEqual(tournament.id, 13420)
        XCTAssertEqual(tournament.slug, "csgo-pgl-major-copenhagen-2026")
        XCTAssertEqual(tournament.name, "Group Stage")
        XCTAssertEqual(tournament.tier, .s)
        XCTAssertEqual(tournament.game, .cs2)
        XCTAssertEqual(tournament.league.name, "PGL")
        XCTAssertEqual(tournament.serie.name, "Major Copenhagen 2026")
        XCTAssertEqual(tournament.country, "DK")
        XCTAssertEqual(tournament.region, "EUROPE")
        XCTAssertTrue(tournament.liveSupported)
        XCTAssertNotNil(tournament.beginAt)
        XCTAssertNotNil(tournament.endAt)
    }

    func test_map_prizepool_parsesAmountAndCurrency() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScoreTournamentDTO.self,
            named: "tournament_running_cs2",
            in: Self.self
        )

        let tournament = try XCTUnwrap(TournamentMapper.map(dto))

        XCTAssertEqual(tournament.prizepool?.amount, Decimal(1_250_000))
        XCTAssertEqual(tournament.prizepool?.currency, "United States Dollar")
    }

    func test_map_missingLeague_returnsNil() throws {
        let payload = """
        {
            "id": 1,
            "slug": "t",
            "name": "T",
            "league": null,
            "serie": { "id": 2, "name": "S" },
            "videogame": { "id": 3, "name": "CS-GO", "slug": "cs-go" }
        }
        """.data(using: .utf8)!
        let decoder = makeDecoder()
        let dto = try decoder.decode(PandaScoreTournamentDTO.self, from: payload)

        XCTAssertNil(TournamentMapper.map(dto))
    }

    func test_map_unknownTier_returnsTournamentWithNilTier() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScoreTournamentDTO.self,
            named: "tournament_running_cs2",
            in: Self.self
        )
        let mutated = PandaScoreTournamentDTO(
            id: dto.id, slug: dto.slug, name: dto.name,
            tier: "zzz",
            beginAt: dto.beginAt, endAt: dto.endAt,
            prizepool: dto.prizepool, country: dto.country, region: dto.region,
            liveSupported: dto.liveSupported, modifiedAt: dto.modifiedAt,
            league: dto.league, serie: dto.serie, videogame: dto.videogame,
            matches: dto.matches, expectedRoster: dto.expectedRoster
        )

        let tournament = try XCTUnwrap(TournamentMapper.map(mutated))

        XCTAssertNil(tournament.tier)
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
