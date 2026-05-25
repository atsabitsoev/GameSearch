//
//  MatchDetailsProtocols.swift
//  GameSearch
//
//  Protocol contracts for the MatchDetails VIPER stack (Phase 1.C).
//  The screen does two fetches: the primary match payload (via
//  `/matches/{id}`, full shape with opponents/results/games/streams)
//  and a secondary lookup of the parent tournament for the caption
//  ("PGL Major · Group Stage"). The tournament fetch is best-effort —
//  caption falls back to the match name when it fails.
//

import Foundation

// MARK: - Interactor

protocol MatchDetailsInteractorProtocol: Sendable {
    func fetchMatch(id: MatchId) async throws -> Match
    func fetchTournament(idOrSlug: String) async throws -> Tournament
    func invalidateCache(matchId: MatchId, tournamentId: TournamentId?) async
}

// MARK: - State

enum MatchDetailsState: Equatable {
    case loading
    case loaded(Match)
    case error(kind: TournamentsEmptyStateView.Kind)
}

/// Tournament caption is loaded best-effort and never fails the screen.
enum MatchDetailsTournamentContextState: Equatable {
    case idle
    case loading
    case loaded(Tournament)
    case unavailable
}

// MARK: - ViewModel

@MainActor
protocol MatchDetailsViewModelProtocol: ObservableObject {
    var state: MatchDetailsState { get }
    var tournamentContext: MatchDetailsTournamentContextState { get }
    var matchId: MatchId { get }

    func onAppear() async
    func onPullToRefresh() async
    func onRetry() async
    func onStreamTapped(_ stream: Stream)
    func onStreamOpenFailed(_ stream: Stream, reason: TournamentsAnalyticsEvent.StreamOpenFailReason)
    func onShareTapped()
    func shareUrl() -> URL?
}
