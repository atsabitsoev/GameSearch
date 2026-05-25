//
//  TournamentDetailsInteractor.swift
//  GameSearch
//
//  Bridges the TournamentDetails ViewModel with the Service layer.
//  Tournament fetch and standings fetch propagate errors so the VM can
//  map them onto error placeholders.
//

import Foundation

final class TournamentDetailsInteractor: TournamentDetailsInteractorProtocol, @unchecked Sendable {

    // MARK: - Dependencies

    private let tournamentsService: TournamentsServiceProtocol
    private let matchesService: MatchesServiceProtocol
    private let cache: CacheStoreProtocol

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

    func fetchTournament(idOrSlug: String) async throws -> Tournament {
        try await tournamentsService.fetchTournamentDetails(idOrSlug: idOrSlug)
    }

    /// Full match payloads via dedicated `/matches?filter[tournament_id]=...`
    /// endpoint. Inline `tournament.matches` are missing opponents/results
    /// and cannot be rendered — see comment on
    /// `MatchesServiceProtocol.fetchTournamentMatches`.
    func fetchTournamentMatches(tournamentId: TournamentId) async throws -> [Match] {
        try await matchesService.fetchTournamentMatches(tournamentId: tournamentId)
    }

    func fetchStandings(tournamentId: TournamentId) async throws -> [Standing] {
        try await tournamentsService.fetchStandings(tournamentId: tournamentId)
    }

    func fetchSeriesStages(serieId: SerieId) async throws -> [Tournament] {
        try await tournamentsService.fetchSeriesTournaments(serieId: serieId)
    }

    func invalidateCache(
        idOrSlug: String,
        tournamentId: TournamentId?,
        serieId: SerieId?
    ) async {
        await cache.invalidate(prefix: "tournament:detail:\(idOrSlug)")
        if let tournamentId {
            await cache.invalidate(prefix: "tournament:standings:\(tournamentId)")
            await cache.invalidate(prefix: "tournament:brackets:\(tournamentId)")
            await cache.invalidate(prefix: "matches:tournament:\(tournamentId)")
        }
        if let serieId {
            await cache.invalidate(prefix: "series:tournaments:\(serieId)")
        }
    }
}
