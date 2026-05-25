//
//  StandingMapperTests.swift
//  GameSearchTests
//
//  Verifies that PandaScore's CS2 standings — which often omit wins,
//  losses and points entirely — map to `Standing` with nil values
//  rather than silently zeroing them out (which would render as
//  "0/0/—" and look like a bug to the user).
//

import XCTest
@testable import GameSearch

final class StandingMapperTests: XCTestCase {

    func test_map_minimalDTO_preservesNilStats() {
        let dto = makeStandingDTO(team: teamDTO(id: 1, name: "Spirit"), rank: 1)

        let standing = StandingMapper.map(dto)

        XCTAssertNotNil(standing)
        XCTAssertEqual(standing?.rank, 1)
        XCTAssertNil(standing?.wins, "wins must stay nil — used to render '—' in the UI")
        XCTAssertNil(standing?.losses, "losses must stay nil — used to render '—' in the UI")
        XCTAssertNil(standing?.ties)
        XCTAssertNil(standing?.points)
        XCTAssertNil(standing?.total)
        XCTAssertNil(standing?.gameWins)
        XCTAssertNil(standing?.gameLosses)
        XCTAssertNil(standing?.gameTies)
    }

    func test_map_groupStageDTO_preservesAllStats() {
        // Mirrors a real PandaScore CS2 group-stage row (e.g. Astana 2026
        // Group Stage, 9z @ rank 1, see Proxyman capture in Phase 1.B
        // bugfix notes).
        let dto = makeStandingDTO(
            team: teamDTO(id: 411, name: "9z"),
            rank: 1,
            wins: 3,
            losses: 0,
            ties: nil,
            points: nil,
            total: 3,
            gameWins: 6,
            gameLosses: 2,
            gameTies: 0
        )

        let standing = StandingMapper.map(dto)

        XCTAssertEqual(standing?.rank, 1)
        XCTAssertEqual(standing?.wins, 3)
        XCTAssertEqual(standing?.losses, 0)
        XCTAssertEqual(standing?.total, 3)
        XCTAssertEqual(standing?.gameWins, 6)
        XCTAssertEqual(standing?.gameLosses, 2)
        XCTAssertEqual(standing?.gameTies, 0)
    }

    func test_map_legacyPointsDTO_preservesPoints() {
        // Other games / older formats may still surface a `points` field.
        // We keep it as a fallback column.
        let dto = makeStandingDTO(
            team: teamDTO(id: 1, name: "Fnatic"),
            rank: 1, wins: 13, losses: 5, points: 18, total: 18,
            gameWins: 13, gameLosses: 5, gameTies: 0
        )

        let standing = StandingMapper.map(dto)

        XCTAssertEqual(standing?.points, 18)
    }

    func test_map_missingTeam_returnsNil() {
        let dto = makeStandingDTO(team: nil, rank: 1)

        XCTAssertNil(StandingMapper.map(dto))
    }

    func test_map_missingRank_returnsNil() {
        let dto = makeStandingDTO(team: teamDTO(id: 1, name: "X"), rank: nil, wins: 1, losses: 0)

        XCTAssertNil(StandingMapper.map(dto))
    }

    func test_mapAll_filtersOutInvalidEntries() {
        let valid = makeStandingDTO(team: teamDTO(id: 1, name: "Spirit"), rank: 1)
        let invalid = makeStandingDTO(team: nil, rank: 2)

        let standings = StandingMapper.mapAll([valid, invalid])

        XCTAssertEqual(standings.count, 1)
        XCTAssertEqual(standings.first?.team.name, "Spirit")
    }
}

// MARK: - Helpers

private func makeStandingDTO(
    team: PandaScoreTeamDTO?,
    rank: Int?,
    wins: Int? = nil,
    losses: Int? = nil,
    ties: Int? = nil,
    points: Int? = nil,
    total: Int? = nil,
    gameWins: Int? = nil,
    gameLosses: Int? = nil,
    gameTies: Int? = nil
) -> PandaScoreStandingDTO {
    PandaScoreStandingDTO(
        team: team,
        rank: rank,
        wins: wins,
        losses: losses,
        ties: ties,
        points: points,
        total: total,
        gameWins: gameWins,
        gameLosses: gameLosses,
        gameTies: gameTies
    )
}

private func teamDTO(id: Int, name: String) -> PandaScoreTeamDTO {
    PandaScoreTeamDTO(
        id: id,
        name: name,
        slug: name.lowercased(),
        acronym: nil,
        location: nil,
        imageUrl: nil,
        currentVideogame: nil,
        players: nil,
        modifiedAt: nil
    )
}

// MARK: - Layout test

final class StandingsColumnLayoutTests: XCTestCase {

    func test_allNilStats_hidesAllStatColumns() {
        let standings = (1...3).map { rank in
            makeStanding(id: rank, rank: rank)
        }

        let layout = StandingsColumnLayout(standings: standings)

        XCTAssertFalse(layout.showsWins)
        XCTAssertFalse(layout.showsLosses)
        XCTAssertFalse(layout.showsTotal)
        XCTAssertFalse(layout.showsMaps)
        XCTAssertFalse(layout.showsPoints)
        XCTAssertFalse(layout.hasAnyStatsColumn)
    }

    func test_groupStage_showsWinsLossesTotalMaps() {
        // Mirror Astana 2026 Group Stage shape.
        let standings = [
            makeStanding(id: 1, rank: 1, wins: 3, losses: 0, total: 3, gameWins: 6, gameLosses: 2),
            makeStanding(id: 2, rank: 3, wins: 3, losses: 1, total: 4, gameWins: 7, gameLosses: 3)
        ]

        let layout = StandingsColumnLayout(standings: standings)

        XCTAssertTrue(layout.showsWins)
        XCTAssertTrue(layout.showsLosses)
        XCTAssertTrue(layout.showsTotal)
        XCTAssertTrue(layout.showsMaps)
        XCTAssertFalse(layout.showsPoints, "CS2 group-stage rows do not carry `points`")
        XCTAssertTrue(layout.hasAnyStatsColumn)
    }

    func test_mapsColumn_showsWhenAnyRowHasEitherSide() {
        // Edge case — one row has gameWins but no gameLosses, another the
        // opposite. We still surface the column.
        let standings = [
            makeStanding(id: 1, rank: 1, gameWins: 6, gameLosses: nil),
            makeStanding(id: 2, rank: 2, gameWins: nil, gameLosses: 3)
        ]

        let layout = StandingsColumnLayout(standings: standings)

        XCTAssertTrue(layout.showsMaps)
    }

    func test_legacyPoints_showsPointsColumn() {
        let standings = [
            makeStanding(id: 1, rank: 1, wins: 13, losses: 5, points: 18)
        ]

        let layout = StandingsColumnLayout(standings: standings)

        XCTAssertTrue(layout.showsPoints)
        XCTAssertTrue(layout.showsWins)
        XCTAssertTrue(layout.showsLosses)
    }
}

private func makeStanding(
    id: Int,
    rank: Int,
    wins: Int? = nil,
    losses: Int? = nil,
    ties: Int? = nil,
    points: Int? = nil,
    total: Int? = nil,
    gameWins: Int? = nil,
    gameLosses: Int? = nil,
    gameTies: Int? = nil
) -> Standing {
    Standing(
        team: .fixture(id: id, name: "T\(id)"),
        rank: rank,
        wins: wins,
        losses: losses,
        ties: ties,
        points: points,
        total: total,
        gameWins: gameWins,
        gameLosses: gameLosses,
        gameTies: gameTies
    )
}
