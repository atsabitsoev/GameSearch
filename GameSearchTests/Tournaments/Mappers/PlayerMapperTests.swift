//
//  PlayerMapperTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class PlayerMapperTests: XCTestCase {

    func test_map_karrigan_parsesBirthdayAndFields() throws {
        let dto = try PandaScoreFixtures.decode(
            PandaScorePlayerDTO.self,
            named: "player_karrigan",
            in: Self.self
        )

        let player = try XCTUnwrap(PlayerMapper.map(dto))

        XCTAssertEqual(player.id, 12345)
        XCTAssertEqual(player.nickname, "karrigan")
        XCTAssertEqual(player.firstName, "Finn")
        XCTAssertEqual(player.lastName, "Andersen")
        XCTAssertEqual(player.displayFullName, "Finn Andersen")
        XCTAssertEqual(player.nationality, "DK")
        XCTAssertEqual(player.age, 35)
        XCTAssertEqual(player.role, "Coach")
        XCTAssertTrue(player.active)
        XCTAssertEqual(player.currentGame, .cs2)
        XCTAssertEqual(player.currentTeam?.id, 411)
        XCTAssertNotNil(player.birthday)
    }

    func test_map_nilName_returnsNil() throws {
        let json = """
        {"id": 1, "first_name": "Anon"}
        """.data(using: .utf8)!
        let decoder = makeDecoder()
        let dto = try decoder.decode(PandaScorePlayerDTO.self, from: json)

        XCTAssertNil(PlayerMapper.map(dto))
    }

    func test_displayFullName_handlesPartialNames() {
        let firstOnly = Player(
            id: 1, nickname: "x", firstName: "First", lastName: nil,
            nationality: nil, age: nil, birthday: nil, role: nil, active: true,
            imageUrl: nil, currentTeam: nil, currentGame: nil
        )
        XCTAssertEqual(firstOnly.displayFullName, "First")

        let lastOnly = Player(
            id: 2, nickname: "y", firstName: nil, lastName: "Last",
            nationality: nil, age: nil, birthday: nil, role: nil, active: true,
            imageUrl: nil, currentTeam: nil, currentGame: nil
        )
        XCTAssertEqual(lastOnly.displayFullName, "Last")

        let neither = Player(
            id: 3, nickname: "z", firstName: nil, lastName: nil,
            nationality: nil, age: nil, birthday: nil, role: nil, active: true,
            imageUrl: nil, currentTeam: nil, currentGame: nil
        )
        XCTAssertNil(neither.displayFullName)
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
