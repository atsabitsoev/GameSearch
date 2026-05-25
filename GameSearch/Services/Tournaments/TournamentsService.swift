//
//  TournamentsService.swift
//  GameSearch
//
//  Domain-layer service for tournaments. Caches via CacheStore, fetches
//  from PandaScore via PandaScoreAPIClient, returns domain models only.
//

import Foundation

// MARK: - Protocol

protocol TournamentsServiceProtocol: Sendable {
    /// Legacy entry-point preserved for Phase 0 tests; defaults to page 1.
    func fetchTournaments(game: Game, segment: TournamentSegment) async throws -> [Tournament]
    /// Phase 1 paginated fetch. Page is 1-based; `pageSize` is capped by
    /// PandaScore at 100, we default to 50 to align with cache TTLs.
    func fetchTournamentsPage(
        game: Game,
        segment: TournamentSegment,
        page: Int,
        pageSize: Int
    ) async throws -> [Tournament]
    func fetchTournamentDetails(idOrSlug: String) async throws -> Tournament
    func fetchStandings(tournamentId: TournamentId) async throws -> [Standing]
    func fetchBrackets(tournamentId: TournamentId) async throws -> Bracket
}

// MARK: - Implementation

final class TournamentsService: TournamentsServiceProtocol, @unchecked Sendable {

    // MARK: - Dependencies

    private let api: PandaScoreAPIClientProtocol
    private let cache: CacheStoreProtocol

    // MARK: - Init

    init(api: PandaScoreAPIClientProtocol, cache: CacheStoreProtocol) {
        self.api = api
        self.cache = cache
    }

    // MARK: - Public

    func fetchTournaments(game: Game, segment: TournamentSegment) async throws -> [Tournament] {
        try await fetchTournamentsPage(game: game, segment: segment, page: 1, pageSize: 50)
    }

    func fetchTournamentsPage(
        game: Game,
        segment: TournamentSegment,
        page: Int = 1,
        pageSize: Int = 50
    ) async throws -> [Tournament] {
        let safePage = max(1, page)
        let safeSize = max(1, min(pageSize, 100))
        let key = cacheKeyList(game: game, segment: segment, page: safePage, pageSize: safeSize)
        let ttl = ttl(forList: segment)

        if let cached: [Tournament] = await cache.read([Tournament].self, key: key) {
            return cached
        }

        let path = "/\(game.pandaScorePrefix)/tournaments/\(segment.pandaScorePath)"
        let query: [URLQueryItem] = [
            URLQueryItem(name: "filter[tier]", value: "s,a"),
            URLQueryItem(name: "page[size]", value: "\(safeSize)"),
            URLQueryItem(name: "page[number]", value: "\(safePage)"),
            URLQueryItem(name: "sort", value: segment == .past ? "-begin_at" : "begin_at")
        ]
        let dtos = try await api.get([PandaScoreTournamentDTO].self, path: path, query: query)
        let tournaments = TournamentMapper.mapAll(dtos)
        await cache.write(tournaments, key: key, ttl: ttl)
        return tournaments
    }

    func fetchTournamentDetails(idOrSlug: String) async throws -> Tournament {
        let key = "tournament:detail:\(idOrSlug)"

        if let cached: Tournament = await cache.read(Tournament.self, key: key) {
            return cached
        }

        let path = "/tournaments/\(idOrSlug)"
        let dto = try await api.get(PandaScoreTournamentDTO.self, path: path, query: [])
        guard let tournament = TournamentMapper.map(dto) else {
            throw TournamentsServiceError.decoding(message: "Tournament \(idOrSlug) failed to map")
        }
        let ttl = tournament.isLive ? TTL.tournamentDetailsLive : TTL.tournamentDetailsStatic
        await cache.write(tournament, key: key, ttl: ttl)
        return tournament
    }

    func fetchStandings(tournamentId: TournamentId) async throws -> [Standing] {
        let key = "tournament:standings:\(tournamentId)"

        if let cached: [Standing] = await cache.read([Standing].self, key: key) {
            return cached
        }

        let path = "/tournaments/\(tournamentId)/standings"
        let dtos = try await api.get([PandaScoreStandingDTO].self, path: path, query: [])
        let standings = StandingMapper.mapAll(dtos)
        await cache.write(standings, key: key, ttl: TTL.standings)
        return standings
    }

    func fetchBrackets(tournamentId: TournamentId) async throws -> Bracket {
        let key = "tournament:brackets:\(tournamentId)"

        if let cached: Bracket = await cache.read(Bracket.self, key: key) {
            return cached
        }

        let path = "/tournaments/\(tournamentId)/brackets"
        let dtos = try await api.get([PandaScoreMatchDTO].self, path: path, query: [])
        let matches = MatchMapper.mapAll(dtos)
        // Phase 0 produces a single-round bracket; Phase 4 will introduce
        // round decomposition based on match metadata.
        let bracket = Bracket(rounds: [Bracket.Round(name: "All matches", matches: matches)])
        await cache.write(bracket, key: key, ttl: TTL.brackets)
        return bracket
    }
}

// MARK: - TTLs and keys

private extension TournamentsService {

    enum TTL {
        static let listRunning: TimeInterval = 5 * 60
        static let listUpcoming: TimeInterval = 30 * 60
        static let listPast: TimeInterval = 24 * 60 * 60
        static let tournamentDetailsLive: TimeInterval = 5 * 60
        static let tournamentDetailsStatic: TimeInterval = 60 * 60
        static let standings: TimeInterval = 5 * 60
        static let brackets: TimeInterval = 5 * 60
    }

    func ttl(forList segment: TournamentSegment) -> TimeInterval {
        switch segment {
        case .running: TTL.listRunning
        case .upcoming: TTL.listUpcoming
        case .past: TTL.listPast
        }
    }

    func cacheKeyList(game: Game, segment: TournamentSegment) -> String {
        "tournaments:list:\(game.rawValue):\(segment.pandaScorePath)"
    }

    /// Page 1 keeps the legacy key for backward compatibility with Phase 0
    /// tests; subsequent pages append a `:p<page>:s<size>` suffix.
    func cacheKeyList(
        game: Game,
        segment: TournamentSegment,
        page: Int,
        pageSize: Int
    ) -> String {
        let base = cacheKeyList(game: game, segment: segment)
        if page == 1, pageSize == 50 {
            return base
        }
        return "\(base):p\(page):s\(pageSize)"
    }
}
