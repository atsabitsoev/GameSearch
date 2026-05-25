//
//  TournamentDetailsProtocols.swift
//  GameSearch
//
//  Protocol contracts for the TournamentDetails VIPER stack. The screen
//  has one primary load (tournament payload incl. matches and expected
//  roster) and one lazy sub-load (standings) triggered when the user
//  switches to the "Таблица" tab.
//

import Foundation

// MARK: - Tab

enum TournamentDetailsTab: Hashable, CaseIterable, Sendable {
    case matches
    case standings
    case brackets
    case participants

    var title: String {
        switch self {
        case .matches: TournamentsStrings.tournamentTabMatches
        case .standings: TournamentsStrings.tournamentTabStandings
        case .brackets: TournamentsStrings.tournamentTabBrackets
        case .participants: TournamentsStrings.tournamentTabParticipants
        }
    }

    var analyticsTab: TournamentsAnalyticsEvent.TournamentTab {
        switch self {
        case .matches: .matches
        case .standings: .standings
        case .brackets: .brackets
        case .participants: .participants
        }
    }
}

// MARK: - Interactor

protocol TournamentDetailsInteractorProtocol: Sendable {
    func fetchTournament(idOrSlug: String) async throws -> Tournament
    func fetchTournamentMatches(tournamentId: TournamentId) async throws -> [Match]
    func fetchStandings(tournamentId: TournamentId) async throws -> [Standing]
    func fetchSeriesStages(serieId: SerieId) async throws -> [Tournament]
    func invalidateCache(idOrSlug: String, tournamentId: TournamentId?, serieId: SerieId?) async
}

// MARK: - State

enum TournamentDetailsState: Equatable {
    case loading
    case loaded(Tournament)
    case error(kind: TournamentsEmptyStateView.Kind)
}

enum TournamentDetailsStandingsState: Equatable {
    case idle
    case loading
    case loaded([Standing])
    case empty
    case error(kind: TournamentsEmptyStateView.Kind)
}

enum TournamentDetailsMatchesState: Equatable {
    case idle
    case loading
    case loaded([Match])
    case empty
    case error(kind: TournamentsEmptyStateView.Kind)
}

/// Loaded sibling stages of the current tournament's series. The picker
/// is only shown when `.loaded` contains 2+ stages — for a one-stage
/// series there is nothing to switch between.
enum TournamentDetailsStagesState: Equatable {
    case idle
    case loaded([Tournament])
}

// MARK: - ViewModel

@MainActor
protocol TournamentDetailsViewModelProtocol: ObservableObject {
    var state: TournamentDetailsState { get }
    var selectedTab: TournamentDetailsTab { get }
    var matchesState: TournamentDetailsMatchesState { get }
    var standingsState: TournamentDetailsStandingsState { get }
    var stagesState: TournamentDetailsStagesState { get }
    var idOrSlug: String { get }

    func setRouteHandler(_ handler: ((TournamentsRoute) -> Void)?)

    func onAppear() async
    func onPullToRefresh() async
    func onRetry() async
    func onMatchesRetry() async
    func onStandingsRetry() async
    func onSelectTab(_ tab: TournamentDetailsTab)
    func onSelectStage(_ stage: Tournament)
    func onTapMatch(_ match: Match)
    func onShareTapped()
}
