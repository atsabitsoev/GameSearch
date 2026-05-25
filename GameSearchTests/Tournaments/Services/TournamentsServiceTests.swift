//
//  TournamentsServiceTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class TournamentsServiceTests: XCTestCase {

    private var apiClient: MockPandaScoreAPIClient!
    private var cache: CacheStore!
    private var sut: TournamentsService!

    override func setUp() {
        super.setUp()
        apiClient = MockPandaScoreAPIClient()
        cache = CacheStore(memory: MemoryCache(), disk: nil)
        sut = TournamentsService(api: apiClient, cache: cache)
    }

    override func tearDown() {
        sut = nil
        cache = nil
        apiClient = nil
        super.tearDown()
    }

    func test_fetchTournaments_whenEmptyCache_callsApi() async throws {
        apiClient.responseHandler = { path, query in
            XCTAssertEqual(path, "/csgo/tournaments/running")
            // No tier filter (Phase 1.C bugfix): listing matches all
            // tiers so the live-strip and the "Сейчас" segment are
            // consistent for the user.
            XCTAssertFalse(query.contains { $0.name == "filter[tier]" })
            XCTAssertTrue(query.contains { $0.name == "page[size]" })
            XCTAssertTrue(query.contains { $0.name == "sort" && $0.value == "begin_at" })
            let dto = try PandaScoreFixtures.decode(
                PandaScoreTournamentDTO.self,
                named: "tournament_running_cs2",
                in: TournamentsServiceTests.self
            )
            return [dto]
        }

        let result = try await sut.fetchTournaments(game: .cs2, segment: .running)

        XCTAssertEqual(apiClient.callCount, 1)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, 13420)
    }

    func test_fetchTournaments_whenFreshCache_doesNotCallApi() async throws {
        let cached = [Tournament.fixture()]
        await cache.write(cached, key: "tournaments:list:cs2:running", ttl: 60)

        let result = try await sut.fetchTournaments(game: .cs2, segment: .running)

        XCTAssertEqual(apiClient.callCount, 0)
        XCTAssertEqual(result.count, 1)
    }

    func test_fetchTournaments_apiError_throws() async {
        apiClient.stubbedError = TournamentsServiceError.serverError(status: 500)

        do {
            _ = try await sut.fetchTournaments(game: .dota2, segment: .upcoming)
            XCTFail("Expected throw")
        } catch let error as TournamentsServiceError {
            XCTAssertEqual(error, .serverError(status: 500))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fetchTournamentDetails_cachesResult() async throws {
        apiClient.responseHandler = { _, _ in
            try PandaScoreFixtures.decode(
                PandaScoreTournamentDTO.self,
                named: "tournament_running_cs2",
                in: TournamentsServiceTests.self
            )
        }

        _ = try await sut.fetchTournamentDetails(idOrSlug: "csgo-pgl-major")
        _ = try await sut.fetchTournamentDetails(idOrSlug: "csgo-pgl-major")

        XCTAssertEqual(apiClient.callCount, 1)
    }

    func test_fetchSeriesTournaments_callsSeriesEndpoint() async throws {
        apiClient.responseHandler = { path, query in
            XCTAssertEqual(path, "/series/10574/tournaments")
            XCTAssertTrue(query.isEmpty)
            return [
                try PandaScoreFixtures.decode(
                    PandaScoreTournamentDTO.self,
                    named: "tournament_running_cs2",
                    in: TournamentsServiceTests.self
                )
            ]
        }

        let stages = try await sut.fetchSeriesTournaments(serieId: 10574)

        XCTAssertEqual(apiClient.callCount, 1)
        XCTAssertEqual(stages.count, 1)
    }

    func test_fetchSeriesTournaments_secondCall_servesFromCache() async throws {
        apiClient.responseHandler = { _, _ in
            [
                try PandaScoreFixtures.decode(
                    PandaScoreTournamentDTO.self,
                    named: "tournament_running_cs2",
                    in: TournamentsServiceTests.self
                )
            ]
        }

        _ = try await sut.fetchSeriesTournaments(serieId: 10574)
        _ = try await sut.fetchSeriesTournaments(serieId: 10574)

        XCTAssertEqual(apiClient.callCount, 1)
    }
}
