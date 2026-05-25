//
//  MatchDetailsInteractor.swift
//  GameSearch
//
//  Bridges the MatchDetails ViewModel with the Service layer. Two
//  fetches:
//  - `MatchesService.fetchMatchDetails(id:)` returns the full match
//    payload (opponents/results/games/streams).
//  - `TournamentsService.fetchTournamentDetails(idOrSlug:)` looks up
//    the parent tournament so the header can render "League · Stage".
//

import Foundation

final class MatchDetailsInteractor: MatchDetailsInteractorProtocol, @unchecked Sendable {

    // MARK: - Dependencies

    private let matchesService: MatchesServiceProtocol
    private let tournamentsService: TournamentsServiceProtocol
    private let cache: CacheStoreProtocol

    // MARK: - Init

    init(
        matchesService: MatchesServiceProtocol,
        tournamentsService: TournamentsServiceProtocol,
        cache: CacheStoreProtocol
    ) {
        self.matchesService = matchesService
        self.tournamentsService = tournamentsService
        self.cache = cache
    }

    // MARK: - Public

    func fetchMatch(id: MatchId) async throws -> Match {
        try await matchesService.fetchMatchDetails(id: id)
    }

    func fetchTournament(idOrSlug: String) async throws -> Tournament {
        try await tournamentsService.fetchTournamentDetails(idOrSlug: idOrSlug)
    }

    func invalidateCache(matchId: MatchId, tournamentId: TournamentId?) async {
        await cache.invalidate(prefix: "match:detail:\(matchId)")
        if let tournamentId {
            await cache.invalidate(prefix: "tournament:detail:\(tournamentId)")
        }
    }
}
