//
//  MatchesService.swift
//  GameSearch
//
//  Domain-layer service for matches. Mirror of TournamentsService for the
//  matches/lives endpoints.
//

import Foundation

// MARK: - Protocol

protocol MatchesServiceProtocol: Sendable {
    func fetchMatches(game: Game, segment: TournamentSegment) async throws -> [Match]
    func fetchMatchDetails(id: MatchId) async throws -> Match
    func fetchLives(game: Game?) async throws -> [Match]
    /// Full match payloads for a tournament — needed because inline
    /// matches inside `/tournaments/{id}` are stripped of `opponents`,
    /// `results`, `league_id`, and `videogame`, which makes them
    /// unrenderable. This endpoint returns the full match shape.
    func fetchTournamentMatches(tournamentId: TournamentId) async throws -> [Match]
}

// MARK: - Implementation

final class MatchesService: MatchesServiceProtocol, @unchecked Sendable {

    // MARK: - Dependencies

    private let api: PandaScoreAPIClientProtocol
    private let cache: CacheStoreProtocol

    // MARK: - Init

    init(api: PandaScoreAPIClientProtocol, cache: CacheStoreProtocol) {
        self.api = api
        self.cache = cache
    }

    // MARK: - Public

    func fetchMatches(game: Game, segment: TournamentSegment) async throws -> [Match] {
        let key = "matches:list:\(game.rawValue):\(segment.pandaScorePath)"
        let ttl = ttl(forList: segment)

        if let cached: [Match] = await cache.read([Match].self, key: key) {
            return cached
        }

        let path = "/\(game.pandaScorePrefix)/matches/\(segment.pandaScorePath)"
        let query: [URLQueryItem] = [
            URLQueryItem(name: "page[size]", value: "50"),
            URLQueryItem(name: "sort", value: segment == .past ? "-begin_at" : "begin_at")
        ]
        let dtos = try await api.get([PandaScoreMatchDTO].self, path: path, query: query)
        let matches = MatchMapper.mapAll(dtos)
        await cache.write(matches, key: key, ttl: ttl)
        return matches
    }

    func fetchMatchDetails(id: MatchId) async throws -> Match {
        let key = "match:detail:\(id)"

        if let cached: Match = await cache.read(Match.self, key: key) {
            return cached
        }

        let path = "/matches/\(id)"
        let dto = try await api.get(PandaScoreMatchDTO.self, path: path, query: [])
        guard let match = MatchMapper.map(dto) else {
            throw TournamentsServiceError.decoding(message: "Match \(id) failed to map")
        }
        let ttl = match.isOver ? TTL.matchDetailsFinished : TTL.matchDetailsLive
        await cache.write(match, key: key, ttl: ttl)
        return match
    }

    func fetchLives(game: Game?) async throws -> [Match] {
        let suffix = game?.rawValue ?? "all"
        let key = "matches:lives:\(suffix)"

        if let cached: [Match] = await cache.read([Match].self, key: key) {
            return cached
        }

        let path: String
        var query: [URLQueryItem] = [URLQueryItem(name: "page[size]", value: "50")]
        if let game {
            path = "/\(game.pandaScorePrefix)/matches/running"
        } else {
            path = "/lives"
            query = []
        }
        let dtos = try await api.get([PandaScoreMatchDTO].self, path: path, query: query)
        let matches = MatchMapper.mapAll(dtos)
        await cache.write(matches, key: key, ttl: TTL.lives)
        return matches
    }

    func fetchTournamentMatches(tournamentId: TournamentId) async throws -> [Match] {
        let key = "matches:tournament:\(tournamentId)"

        if let cached: [Match] = await cache.read([Match].self, key: key) {
            return cached
        }

        let query: [URLQueryItem] = [
            URLQueryItem(name: "filter[tournament_id]", value: "\(tournamentId)"),
            URLQueryItem(name: "page[size]", value: "100"),
            URLQueryItem(name: "sort", value: "begin_at")
        ]
        let dtos = try await api.get([PandaScoreMatchDTO].self, path: "/matches", query: query)
        let matches = MatchMapper.mapAll(dtos)
        // Live matches need fresh data; finished/canceled-only sets can sit
        // for longer. Pick the shorter TTL whenever anything is still live.
        let ttl: TimeInterval = matches.contains(where: { $0.isLive })
            ? TTL.tournamentMatchesLive
            : TTL.tournamentMatchesStatic
        await cache.write(matches, key: key, ttl: ttl)
        return matches
    }
}

// MARK: - TTLs

private extension MatchesService {

    enum TTL {
        static let listRunning: TimeInterval = 30
        static let listUpcoming: TimeInterval = 5 * 60
        static let listPast: TimeInterval = 24 * 60 * 60
        static let matchDetailsLive: TimeInterval = 30
        static let matchDetailsFinished: TimeInterval = 24 * 60 * 60
        static let lives: TimeInterval = 30
        static let tournamentMatchesLive: TimeInterval = 60
        static let tournamentMatchesStatic: TimeInterval = 60 * 60
    }

    func ttl(forList segment: TournamentSegment) -> TimeInterval {
        switch segment {
        case .running: TTL.listRunning
        case .upcoming: TTL.listUpcoming
        case .past: TTL.listPast
        }
    }
}
