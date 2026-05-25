//
//  TeamMapperTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class TeamMapperTests: XCTestCase {

    func test_map_faze_mapsAllFields() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScoreTeamDTO.self,
            named: "team_faze",
            in: Self.self
        )

        let team = try XCTUnwrap(TeamMapper.map(dto))

        XCTAssertEqual(team.id, 411)
        XCTAssertEqual(team.name, "FaZe Clan")
        XCTAssertEqual(team.slug, "faze-clan")
        XCTAssertEqual(team.acronym, "FAZE")
        XCTAssertEqual(team.location, "EU")
        XCTAssertEqual(team.imageUrl?.absoluteString, "https://cdn-api.pandascore.co/images/faze.png")
        XCTAssertEqual(team.currentGame, .cs2)
        XCTAssertEqual(team.players?.count, 1)
        XCTAssertEqual(team.players?.first?.nickname, "karrigan")
    }

    func test_map_missingId_returnsNil() throws {
        let json = """
        {"name": "X", "slug": "x"}
        """.data(using: .utf8)!
        let dto = try makeDecoder().decode(PandaScoreTeamDTO.self, from: json)

        XCTAssertNil(TeamMapper.map(dto))
    }

    func test_map_missingName_returnsNil() throws {
        let json = """
        {"id": 1, "slug": "x"}
        """.data(using: .utf8)!
        let dto = try makeDecoder().decode(PandaScoreTeamDTO.self, from: json)

        XCTAssertNil(TeamMapper.map(dto))
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
