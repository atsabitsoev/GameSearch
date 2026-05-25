//
//  TournamentsListProtocols.swift
//  GameSearch
//
//  Protocol contracts for the TournamentsList VIPER stack and the data
//  envelope returned by the interactor.
//

import Foundation

// MARK: - Data envelopes

struct TournamentsListPage: Sendable, Equatable {
    let tournaments: [Tournament]
    let hasMore: Bool
}

// MARK: - Interactor

protocol TournamentsListInteractorProtocol: Sendable {
    func fetchTournamentsPage(
        game: Game,
        segment: TournamentSegment,
        page: Int,
        pageSize: Int
    ) async throws -> TournamentsListPage

    /// Best-effort fetch. Returns `[]` if anything goes wrong; never throws.
    func fetchLiveMatches(game: Game) async -> [Match]

    /// Invalidates the cache so the next fetch hits the network.
    func invalidateCache(game: Game, segment: TournamentSegment) async
}

// MARK: - ViewModel

@MainActor
protocol TournamentsListViewModelProtocol: ObservableObject {
    var state: TournamentsListState { get }
    var selectedGame: Game { get }
    var selectedSegment: TournamentSegment { get }
    var liveMatches: [Match] { get }
    var isLoadingNextPage: Bool { get }

    func setRouteHandler(_ handler: ((TournamentsRoute) -> Void)?)

    func onAppear() async
    func onPullToRefresh() async
    func onRetry() async
    func onSelectGame(_ game: Game)
    func onSelectSegment(_ segment: TournamentSegment)
    func onSeriesTapped(_ group: TournamentSeriesGroup)
    func onLiveMatchTapped(_ match: Match, position: Int)
    func onGroupAppear(_ group: TournamentSeriesGroup)
}

// MARK: - State

enum TournamentsListState: Equatable {
    case loading
    case loaded(groups: [TournamentSeriesGroup])
    case empty(kind: TournamentsEmptyStateView.Kind)
    case error(kind: TournamentsEmptyStateView.Kind)

    var groups: [TournamentSeriesGroup] {
        if case .loaded(let groups) = self { return groups }
        return []
    }
}
