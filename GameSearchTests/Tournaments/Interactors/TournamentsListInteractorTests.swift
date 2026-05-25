//
//  TournamentsListInteractorTests.swift
//  GameSearchTests
//
//  Covers the sibling-stage enrichment introduced as a bugfix for
//  "first tournament has no prize pool" — PandaScore only attaches the
//  prize pool to the Playoffs/Final stage of a series, so the listing
//  endpoint may return a series whose only running stage (e.g. Group
//  Stage) has `prizepool == nil`. The interactor must fan out to
//  `/series/<id>/tournaments` to recover the missing stages so the
//  card on the list can render the prize pool from any sibling stage.
//

import XCTest
@testable import GameSearch

@MainActor
final class TournamentsListInteractorTests: XCTestCase {

    private var tournamentsService: SpyTournamentsService!
    private var matchesService: StubMatchesService!
    private var cache: CacheStore!
    private var sut: TournamentsListInteractor!

    override func setUp() {
        super.setUp()
        tournamentsService = SpyTournamentsService()
        matchesService = StubMatchesService()
        cache = CacheStore(memory: MemoryCache(), disk: nil)
        sut = TournamentsListInteractor(
            tournamentsService: tournamentsService,
            matchesService: matchesService,
            cache: cache
        )
    }

    override func tearDown() {
        sut = nil
        cache = nil
        matchesService = nil
        tournamentsService = nil
        super.tearDown()
    }

    func test_fetchTournamentsPage_seriesWithoutPrizepool_fetchesSiblingStages() async throws {
        let groupStage = Tournament.testFixture(
            id: 21029,
            serieId: 10616,
            name: "Group Stage",
            tier: .c,
            prizepool: nil
        )
        let playoffs = Tournament.testFixture(
            id: 21038,
            serieId: 10616,
            name: "Playoffs",
            tier: .c,
            prizepool: Prizepool(amount: 50_000, currency: "United States Dollar")
        )

        tournamentsService.pageResult = [groupStage]
        tournamentsService.siblingResults = [10616: [groupStage, playoffs]]

        let page = try await sut.fetchTournamentsPage(
            game: .cs2,
            segment: .running,
            page: 1,
            pageSize: 30
        )

        XCTAssertEqual(tournamentsService.siblingsRequested, [10616])
        XCTAssertEqual(page.tournaments.map(\.id).sorted(), [21029, 21038])
        let group = TournamentSeriesGroup
            .makeGroups(from: page.tournaments)
            .first { $0.serie.id == 10616 }
        XCTAssertNotNil(group?.prizepool)
        XCTAssertEqual(group?.prizepool?.amount, 50_000)
    }

    func test_fetchTournamentsPage_seriesAlreadyHasPrizepool_skipsSiblingFetch() async throws {
        let playoffs = Tournament.testFixture(
            id: 21038,
            serieId: 10616,
            name: "Playoffs",
            tier: .c,
            prizepool: Prizepool(amount: 50_000, currency: "United States Dollar")
        )
        tournamentsService.pageResult = [playoffs]

        let page = try await sut.fetchTournamentsPage(
            game: .cs2,
            segment: .running,
            page: 1,
            pageSize: 30
        )

        XCTAssertEqual(tournamentsService.siblingsRequested, [])
        XCTAssertEqual(page.tournaments.map(\.id), [21038])
    }

    func test_fetchTournamentsPage_siblingFetchFails_listKeepsRendering() async throws {
        let groupStage = Tournament.testFixture(
            id: 21029,
            serieId: 10616,
            name: "Group Stage",
            tier: .c,
            prizepool: nil
        )
        tournamentsService.pageResult = [groupStage]
        tournamentsService.siblingError = TournamentsServiceError.serverError(status: 500)

        let page = try await sut.fetchTournamentsPage(
            game: .cs2,
            segment: .running,
            page: 1,
            pageSize: 30
        )

        XCTAssertEqual(tournamentsService.siblingsRequested, [10616])
        XCTAssertEqual(page.tournaments.map(\.id), [21029])
    }

    func test_fetchTournamentsPage_hasMore_isComputedOnOriginalPage_notEnrichedSize() async throws {
        let stages = (0..<30).map { idx in
            Tournament.testFixture(
                id: 30_000 + idx,
                serieId: SerieId(10_000 + idx),
                name: "Group Stage",
                tier: .d,
                prizepool: nil
            )
        }
        tournamentsService.pageResult = stages
        // Each serie gets enriched with one extra stage carrying a prize.
        tournamentsService.siblingResults = Dictionary(
            uniqueKeysWithValues: stages.map { stage in
                let extra = Tournament.testFixture(
                    id: stage.id + 100_000,
                    serieId: stage.serie.id,
                    name: "Playoffs",
                    tier: .d,
                    prizepool: Prizepool(amount: 10_000, currency: "United States Dollar")
                )
                return (stage.serie.id, [stage, extra])
            }
        )

        let page = try await sut.fetchTournamentsPage(
            game: .cs2,
            segment: .running,
            page: 1,
            pageSize: 30
        )

        XCTAssertTrue(page.hasMore, "hasMore must reflect the original 30 items, not the enriched 60")
        XCTAssertEqual(page.tournaments.count, 60)
    }
}

// MARK: - Test doubles

private final class SpyTournamentsService: TournamentsServiceProtocol, @unchecked Sendable {
    var pageResult: [Tournament] = []
    var siblingResults: [SerieId: [Tournament]] = [:]
    var siblingError: Error?

    // `fetchSeriesTournaments` is called concurrently from `withTaskGroup`
    // inside the SUT, so we must serialize mutation of the recording array.
    private let lock = NSLock()
    private var _siblingsRequested: [SerieId] = []

    var siblingsRequested: [SerieId] {
        lock.lock(); defer { lock.unlock() }
        return _siblingsRequested
    }

    func fetchTournaments(game: Game, segment: TournamentSegment) async throws -> [Tournament] {
        pageResult
    }

    func fetchTournamentsPage(
        game: Game,
        segment: TournamentSegment,
        page: Int,
        pageSize: Int
    ) async throws -> [Tournament] {
        pageResult
    }

    func fetchTournamentDetails(idOrSlug: String) async throws -> Tournament {
        throw TournamentsServiceError.unknown(message: "not implemented in spy")
    }

    func fetchStandings(tournamentId: TournamentId) async throws -> [Standing] {
        []
    }

    func fetchBrackets(tournamentId: TournamentId) async throws -> Bracket {
        Bracket(rounds: [])
    }

    func fetchSeriesTournaments(serieId: SerieId) async throws -> [Tournament] {
        lock.lock()
        _siblingsRequested.append(serieId)
        lock.unlock()
        if let error = siblingError { throw error }
        return siblingResults[serieId] ?? []
    }
}

private final class StubMatchesService: MatchesServiceProtocol, @unchecked Sendable {
    func fetchMatches(game: Game, segment: TournamentSegment) async throws -> [Match] { [] }
    func fetchMatchDetails(id: MatchId) async throws -> Match {
        throw TournamentsServiceError.unknown(message: "not implemented in stub")
    }
    func fetchLives(game: Game?) async throws -> [Match] { [] }
    func fetchTournamentMatches(tournamentId: TournamentId) async throws -> [Match] { [] }
}

// MARK: - Tournament fixture helper

private extension Tournament {
    static func testFixture(
        id: TournamentId,
        serieId: SerieId,
        name: String,
        tier: Tier?,
        prizepool: Prizepool?,
        beginAt: Date = Date()
    ) -> Tournament {
        Tournament(
            id: id,
            slug: "stage-\(id)",
            name: name,
            tier: tier,
            game: .cs2,
            league: League(id: 1, name: "Test League", slug: "test-league", imageUrl: nil),
            serie: Serie(
                id: serieId,
                name: "Series \(serieId)",
                fullName: "Series \(serieId) 2026",
                year: 2026,
                season: nil
            ),
            beginAt: beginAt,
            endAt: beginAt.addingTimeInterval(86400 * 7),
            prizepool: prizepool,
            country: nil,
            region: nil,
            liveSupported: false,
            modifiedAt: nil,
            matches: nil,
            participants: nil
        )
    }
}
