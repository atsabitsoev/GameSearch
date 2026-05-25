//
//  MatchesServiceTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class MatchesServiceTests: XCTestCase {

    private var apiClient: MockPandaScoreAPIClient!
    private var cache: CacheStore!
    private var sut: MatchesService!

    override func setUp() {
        super.setUp()
        apiClient = MockPandaScoreAPIClient()
        cache = CacheStore(memory: MemoryCache(), disk: nil)
        sut = MatchesService(api: apiClient, cache: cache)
    }

    override func tearDown() {
        sut = nil
        cache = nil
        apiClient = nil
        super.tearDown()
    }

    func test_fetchMatches_running_hitsCorrectEndpoint() async throws {
        apiClient.responseHandler = { path, _ in
            XCTAssertEqual(path, "/csgo/matches/running")
            let dto = try PandaScoreFixtures.decode(
                PandaScoreMatchDTO.self,
                named: "match_running",
                in: MatchesServiceTests.self
            )
            return [dto]
        }

        let result = try await sut.fetchMatches(game: .cs2, segment: .running)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, 1_071_234)
    }

    func test_fetchMatchDetails_cachesResult() async throws {
        apiClient.responseHandler = { path, _ in
            XCTAssertEqual(path, "/matches/1071234")
            return try PandaScoreFixtures.decode(
                PandaScoreMatchDTO.self,
                named: "match_running",
                in: MatchesServiceTests.self
            )
        }

        _ = try await sut.fetchMatchDetails(id: 1_071_234)
        _ = try await sut.fetchMatchDetails(id: 1_071_234)

        XCTAssertEqual(apiClient.callCount, 1)
    }

    func test_fetchLives_withGame_callsGameSpecificEndpoint() async throws {
        apiClient.responseHandler = { path, _ in
            XCTAssertEqual(path, "/dota2/matches/running")
            return [PandaScoreMatchDTO]()
        }

        let result = try await sut.fetchLives(game: .dota2)

        XCTAssertEqual(result.count, 0)
        XCTAssertEqual(apiClient.callCount, 1)
    }

    func test_fetchLives_withoutGame_callsLivesEndpoint() async throws {
        apiClient.responseHandler = { path, _ in
            XCTAssertEqual(path, "/lives")
            return [PandaScoreMatchDTO]()
        }

        _ = try await sut.fetchLives(game: nil)

        XCTAssertEqual(apiClient.callCount, 1)
    }

    func test_fetchTournamentMatches_callsMatchesEndpointWithFilter() async throws {
        apiClient.responseHandler = { path, query in
            XCTAssertEqual(path, "/matches")
            XCTAssertTrue(query.contains {
                $0.name == "filter[tournament_id]" && $0.value == "20930"
            })
            XCTAssertTrue(query.contains {
                $0.name == "page[size]" && $0.value == "100"
            })
            XCTAssertTrue(query.contains {
                $0.name == "sort" && $0.value == "begin_at"
            })
            let dto = try PandaScoreFixtures.decode(
                PandaScoreMatchDTO.self,
                named: "match_running",
                in: MatchesServiceTests.self
            )
            return [dto]
        }

        let result = try await sut.fetchTournamentMatches(tournamentId: 20930)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(apiClient.callCount, 1)
    }

    func test_fetchTournamentMatches_secondCall_servesFromCache() async throws {
        var calls = 0
        apiClient.responseHandler = { _, _ in
            calls += 1
            let dto = try PandaScoreFixtures.decode(
                PandaScoreMatchDTO.self,
                named: "match_running",
                in: MatchesServiceTests.self
            )
            return [dto]
        }

        _ = try await sut.fetchTournamentMatches(tournamentId: 12345)
        _ = try await sut.fetchTournamentMatches(tournamentId: 12345)

        XCTAssertEqual(calls, 1)
    }
}
