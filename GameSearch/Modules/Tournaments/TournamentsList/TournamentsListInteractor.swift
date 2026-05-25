//
//  TournamentsListInteractor.swift
//  GameSearch
//
//  Bridges the TournamentsList ViewModel with the Service layer.
//  Tournaments fetch propagates errors; live matches are best-effort.
//

import Foundation
import os.log

final class TournamentsListInteractor: TournamentsListInteractorProtocol, @unchecked Sendable {

    // MARK: - Dependencies

    private let tournamentsService: TournamentsServiceProtocol
    private let matchesService: MatchesServiceProtocol
    private let cache: CacheStoreProtocol
    private let log = Logger(subsystem: "com.bitsoev.gamesearchea", category: "TournamentsList")

    // MARK: - Init

    init(
        tournamentsService: TournamentsServiceProtocol,
        matchesService: MatchesServiceProtocol,
        cache: CacheStoreProtocol
    ) {
        self.tournamentsService = tournamentsService
        self.matchesService = matchesService
        self.cache = cache
    }

    // MARK: - Public

    func fetchTournamentsPage(
        game: Game,
        segment: TournamentSegment,
        page: Int,
        pageSize: Int
    ) async throws -> TournamentsListPage {
        let items = try await tournamentsService.fetchTournamentsPage(
            game: game,
            segment: segment,
            page: page,
            pageSize: pageSize
        )
        let hasMore = items.count >= pageSize
        return TournamentsListPage(tournaments: items, hasMore: hasMore)
    }

    func fetchLiveMatches(game: Game) async -> [Match] {
        do {
            return try await matchesService.fetchLives(game: game)
        } catch {
            log.error("Live matches fetch failed: \(String(describing: error), privacy: .public)")
            return []
        }
    }

    func invalidateCache(game: Game, segment: TournamentSegment) async {
        await cache.invalidate(prefix: "tournaments:list:\(game.rawValue):\(segment.pandaScorePath)")
        await cache.invalidate(prefix: "matches:lives:")
    }
}
