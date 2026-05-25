//
//  TournamentDetailsViewModel.swift
//  GameSearch
//
//  Drives `TournamentDetailsView`. Owns the main load state (tournament
//  payload) plus a separate lazy state for the standings tab. Tap-on-
//  match routing is delegated via a closure handler set by the screen
//  on appear, so the VM does not own the EnvironmentObject router.
//

import Foundation

@MainActor
final class TournamentDetailsViewModel: TournamentDetailsViewModelProtocol {

    // MARK: - Published

    @Published private(set) var state: TournamentDetailsState = .loading
    @Published private(set) var selectedTab: TournamentDetailsTab = .matches
    @Published private(set) var matchesState: TournamentDetailsMatchesState = .idle
    @Published private(set) var standingsState: TournamentDetailsStandingsState = .idle
    @Published private(set) var stagesState: TournamentDetailsStagesState = .idle

    // MARK: - Identity

    /// Slug or numeric id the screen was originally opened with — used as
    /// a stable cache invalidation handle and for share-link fallback.
    /// The *active* stage may differ after the user picks another stage
    /// via the stage picker (we re-fetch using `activeIdOrSlug`).
    let idOrSlug: String

    /// Currently displayed stage. Starts as `idOrSlug` and switches when
    /// the user taps another stage in the stage picker.
    private var activeIdOrSlug: String

    // MARK: - Routing

    private var pushRoute: ((TournamentsRoute) -> Void)?

    func setRouteHandler(_ handler: ((TournamentsRoute) -> Void)?) {
        pushRoute = handler
    }

    // MARK: - Dependencies

    private let interactor: TournamentDetailsInteractorProtocol
    private let analytics: TournamentsAnalyticsReporting

    // MARK: - State (private)

    private var loadTask: Task<Void, Never>?
    private var matchesTask: Task<Void, Never>?
    private var standingsTask: Task<Void, Never>?
    private var stagesTask: Task<Void, Never>?

    /// Monotonic generation so a stale fetch can self-cancel when the
    /// screen issues a newer request (refresh / retry / stage switch).
    private var loadGeneration: UInt64 = 0
    private var matchesGeneration: UInt64 = 0
    private var standingsGeneration: UInt64 = 0
    private var stagesGeneration: UInt64 = 0

    /// Tracks which tabs were already auto-loaded so we don't refire the
    /// same fetch on each tab switch.
    private var standingsRequested: Bool = false

    /// Serie id we already kicked off stage-list fetch for. Prevents a
    /// second `loadStages` call when the user just switches stages
    /// inside the same series (no need to refetch siblings).
    private var stagesRequestedForSerieId: SerieId?

    // MARK: - Init

    init(
        idOrSlug: String,
        interactor: TournamentDetailsInteractorProtocol,
        analytics: TournamentsAnalyticsReporting = TournamentsAnalytics.shared
    ) {
        self.idOrSlug = idOrSlug
        self.activeIdOrSlug = idOrSlug
        self.interactor = interactor
        self.analytics = analytics
    }

    deinit {
        loadTask?.cancel()
        matchesTask?.cancel()
        standingsTask?.cancel()
        stagesTask?.cancel()
    }

    // MARK: - Intents

    func onAppear() async {
        if case .loaded = state { return }
        await loadTournament()
    }

    func onPullToRefresh() async {
        analytics.report(.pulledToRefresh(screen: .details))
        let currentTournamentId: TournamentId?
        let currentSerieId: SerieId?
        if case .loaded(let tournament) = state {
            currentTournamentId = tournament.id
            currentSerieId = tournament.serie.id
        } else {
            currentTournamentId = nil
            currentSerieId = nil
        }
        await interactor.invalidateCache(
            idOrSlug: activeIdOrSlug,
            tournamentId: currentTournamentId,
            serieId: currentSerieId
        )
        standingsRequested = false
        standingsState = .idle
        matchesState = .idle
        stagesRequestedForSerieId = nil
        await loadTournament()
        if case .loaded(let tournament) = state {
            // Matches are the default tab — always refetch.
            await loadMatches(tournamentId: tournament.id)
            if selectedTab == .standings {
                await loadStandings(tournamentId: tournament.id)
            }
        }
    }

    func onRetry() async {
        if case .error(let kind) = state {
            analytics.report(.errorRetryTapped(screen: .details, kind: errorKindToAnalytics(kind)))
        }
        await loadTournament()
    }

    func onMatchesRetry() async {
        guard case .loaded(let tournament) = state else { return }
        if case .error(let kind) = matchesState {
            analytics.report(.errorRetryTapped(screen: .details, kind: errorKindToAnalytics(kind)))
        }
        await loadMatches(tournamentId: tournament.id)
    }

    func onStandingsRetry() async {
        guard case .loaded(let tournament) = state else { return }
        if case .error(let kind) = standingsState {
            analytics.report(.errorRetryTapped(screen: .details, kind: errorKindToAnalytics(kind)))
        }
        await loadStandings(tournamentId: tournament.id)
    }

    func onSelectTab(_ tab: TournamentDetailsTab) {
        guard selectedTab != tab else { return }
        selectedTab = tab
        if case .loaded(let tournament) = state {
            analytics.report(.tournamentTabSwitched(id: tournament.id, tab: tab.analyticsTab))
        }
        if tab == .standings, case .loaded(let tournament) = state, !standingsRequested {
            standingsTask?.cancel()
            standingsTask = Task { [weak self] in
                await self?.loadStandings(tournamentId: tournament.id)
            }
        }
    }

    func onTapMatch(_ match: Match) {
        analytics.report(.matchOpened(id: match.id, status: match.status, fromScreen: .tournament))
        pushRoute?(.matchDetails(id: match.id))
    }

    func onShareTapped() {
        guard case .loaded(let tournament) = state else { return }
        analytics.report(.tournamentShared(id: tournament.id, slug: tournament.slug))
    }

    /// User picked another stage of the same series. Re-loads tournament
    /// details + matches + standings for that stage. The stage list
    /// itself is reused (same series) — no need to refetch siblings.
    func onSelectStage(_ stage: Tournament) {
        guard case .loaded(let current) = state, current.id != stage.id else { return }
        analytics.report(.tournamentStageSwitched(
            fromStageId: current.id,
            toStageId: stage.id,
            serieId: current.serie.id
        ))
        activeIdOrSlug = stage.slug.isEmpty ? String(stage.id) : stage.slug
        // Reset sub-states so the user sees the loading state for the new
        // stage instead of stale rows from the previous one.
        matchesState = .idle
        standingsState = .idle
        standingsRequested = false
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadTournament()
        }
    }
}

// MARK: - Loading

private extension TournamentDetailsViewModel {

    func loadTournament() async {
        loadGeneration &+= 1
        let generation = loadGeneration
        let snapshotIdOrSlug = activeIdOrSlug

        if case .loaded = state {
            // Keep currently-rendered data; pull-to-refresh triggers a soft refresh.
        } else {
            state = .loading
        }

        do {
            let tournament = try await interactor.fetchTournament(idOrSlug: snapshotIdOrSlug)
            guard generation == loadGeneration, snapshotIdOrSlug == activeIdOrSlug else { return }
            state = .loaded(tournament)
            // Matches tab is the default one — load full match payloads
            // immediately so the user sees them without an extra tap.
            matchesTask?.cancel()
            matchesTask = Task { [weak self] in
                await self?.loadMatches(tournamentId: tournament.id)
            }
            // Stage siblings — only fetched once per series.
            if stagesRequestedForSerieId != tournament.serie.id {
                stagesRequestedForSerieId = tournament.serie.id
                stagesTask?.cancel()
                stagesTask = Task { [weak self] in
                    await self?.loadStages(serieId: tournament.serie.id)
                }
            }
        } catch is CancellationError {
            return
        } catch {
            guard generation == loadGeneration, snapshotIdOrSlug == activeIdOrSlug else { return }
            let kind = errorKind(for: error)
            state = .error(kind: kind)
            analytics.report(.errorShown(screen: .details, kind: errorKindToAnalytics(kind)))
        }
    }

    func loadStages(serieId: SerieId) async {
        stagesGeneration &+= 1
        let generation = stagesGeneration
        do {
            let stages = try await interactor.fetchSeriesStages(serieId: serieId)
            guard generation == stagesGeneration else { return }
            // Render stage picker only when there's something to switch to.
            if stages.count > 1 {
                let sorted = sortedStages(stages)
                stagesState = .loaded(sorted)
            } else {
                stagesState = .idle
            }
        } catch is CancellationError {
            return
        } catch {
            // Silent fallback — stage picker is enhancement, not core.
            // Keep `.idle` so the picker just doesn't show.
            return
        }
    }

    func sortedStages(_ stages: [Tournament]) -> [Tournament] {
        stages.sorted { lhs, rhs in
            switch (lhs.beginAt, rhs.beginAt) {
            case let (l?, r?) where l != r: return l < r
            case (nil, _?): return false
            case (_?, nil): return true
            default:
                if lhs.name != rhs.name { return lhs.name < rhs.name }
                return lhs.id < rhs.id
            }
        }
    }

    func loadMatches(tournamentId: TournamentId) async {
        matchesGeneration &+= 1
        let generation = matchesGeneration
        matchesState = .loading

        do {
            let matches = try await interactor.fetchTournamentMatches(tournamentId: tournamentId)
            guard generation == matchesGeneration else { return }
            if matches.isEmpty {
                matchesState = .empty
            } else {
                matchesState = .loaded(matches)
            }
        } catch is CancellationError {
            return
        } catch {
            guard generation == matchesGeneration else { return }
            let kind = errorKind(for: error)
            matchesState = .error(kind: kind)
        }
    }

    func loadStandings(tournamentId: TournamentId) async {
        standingsGeneration &+= 1
        let generation = standingsGeneration
        standingsRequested = true
        standingsState = .loading

        do {
            let standings = try await interactor.fetchStandings(tournamentId: tournamentId)
            guard generation == standingsGeneration else { return }
            if standings.isEmpty {
                standingsState = .empty
            } else {
                standingsState = .loaded(standings)
            }
        } catch is CancellationError {
            return
        } catch {
            guard generation == standingsGeneration else { return }
            let kind = errorKind(for: error)
            standingsState = .error(kind: kind)
        }
    }

    func errorKind(for error: Error) -> TournamentsEmptyStateView.Kind {
        let mapped = TournamentsServiceError.wrap(error)
        switch mapped {
        case .noNetwork: return .errorNoInternet
        default: return .errorTemporary
        }
    }

    func errorKindToAnalytics(_ kind: TournamentsEmptyStateView.Kind) -> TournamentsAnalyticsEvent.ErrorKind {
        switch kind {
        case .errorNoInternet: .noInternet
        case .errorTemporary, .emptyRunning, .emptyUpcoming, .emptyPast: .temporary
        }
    }
}
