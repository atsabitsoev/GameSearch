//
//  TournamentsListViewModel.swift
//  GameSearch
//
//  Drives `TournamentsListView`. Owns the current game/segment selection,
//  pagination state, and translation between domain errors and the
//  empty/error placeholder kinds.
//

import Foundation

@MainActor
final class TournamentsListViewModel: TournamentsListViewModelProtocol {

    // MARK: - Constants

    private enum Constants {
        static let pageSize: Int = 30
        static let preloadOffset: Int = 4
    }

    // MARK: - Published

    @Published private(set) var state: TournamentsListState = .loading
    @Published private(set) var selectedGame: Game = .cs2
    @Published private(set) var selectedSegment: TournamentSegment = .running
    @Published private(set) var liveMatches: [Match] = []
    @Published private(set) var isLoadingNextPage: Bool = false

    // MARK: - Routing

    /// Set by the screen on appear so the VM can navigate without owning a
    /// reference to the EnvironmentObject router.
    private var pushRoute: ((TournamentsRoute) -> Void)?

    func setRouteHandler(_ handler: ((TournamentsRoute) -> Void)?) {
        pushRoute = handler
    }

    // MARK: - Dependencies

    private let interactor: TournamentsListInteractorProtocol
    private let analytics: TournamentsAnalyticsReporting

    // MARK: - State (private)

    private var allTournaments: [Tournament] = []
    private var nextPageToLoad: Int = 1
    private var hasMorePages: Bool = true
    private var hasLoadedInitial: Bool = false

    private var loadTask: Task<Void, Never>?
    private var liveTask: Task<Void, Never>?
    private var paginationTask: Task<Void, Never>?

    /// Monotonic generation counter. Lets late responses from a stale
    /// `loadCurrent` ignore themselves if the user switched game/segment.
    private var loadGeneration: UInt64 = 0
    private var pageGeneration: UInt64 = 0

    private var liveStripShownCount: Int = -1

    // MARK: - Init

    init(
        interactor: TournamentsListInteractorProtocol,
        analytics: TournamentsAnalyticsReporting = TournamentsAnalytics.shared
    ) {
        self.interactor = interactor
        self.analytics = analytics
    }

    deinit {
        loadTask?.cancel()
        liveTask?.cancel()
        paginationTask?.cancel()
    }

    // MARK: - Intents

    func onAppear() async {
        if !hasLoadedInitial {
            analytics.report(.tabOpened)
            await loadCurrent(reason: .initial)
        } else {
            // Refresh live strip on every tab return; tournaments come from cache.
            await refreshLiveMatches()
        }
    }

    func onPullToRefresh() async {
        analytics.report(.pulledToRefresh(screen: .list))
        await interactor.invalidateCache(game: selectedGame, segment: selectedSegment)
        await loadCurrent(reason: .refresh)
    }

    func onRetry() async {
        if case .error(let kind) = state {
            analytics.report(.errorRetryTapped(screen: .list, kind: errorKindToAnalytics(kind)))
        }
        await loadCurrent(reason: .initial)
    }

    func onSelectGame(_ game: Game) {
        guard selectedGame != game else { return }
        selectedGame = game
        analytics.report(.gameSwitched(game: game))
        liveStripShownCount = -1
        loadTask?.cancel()
        liveTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadCurrent(reason: .initial)
        }
    }

    func onSelectSegment(_ segment: TournamentSegment) {
        guard selectedSegment != segment else { return }
        selectedSegment = segment
        analytics.report(.segmentSwitched(segment: segment))
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadCurrent(reason: .initial)
        }
    }

    func onSeriesTapped(_ group: TournamentSeriesGroup) {
        let stage = group.representativeStage(for: selectedSegment)
        analytics.report(.tournamentOpened(
            id: stage.id,
            slug: stage.slug,
            fromScreen: .list
        ))
        let target = stage.slug.isEmpty ? String(stage.id) : stage.slug
        pushRoute?(.tournamentDetails(idOrSlug: target))
    }

    func onLiveMatchTapped(_ match: Match, position: Int) {
        analytics.report(.liveStripChipTapped(matchId: match.id, position: position))
        analytics.report(.matchOpened(
            id: match.id,
            status: match.status,
            fromScreen: .liveStrip
        ))
        pushRoute?(.matchDetails(id: match.id))
    }

    func onGroupAppear(_ group: TournamentSeriesGroup) {
        guard hasMorePages, !isLoadingNextPage else { return }
        let groups = state.groups
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        let threshold = max(groups.count - Constants.preloadOffset, 0)
        if index >= threshold {
            loadNextPage()
        }
    }
}

// MARK: - Loading

private extension TournamentsListViewModel {

    enum LoadReason {
        case initial
        case refresh
    }

    func loadCurrent(reason: LoadReason) async {
        loadGeneration &+= 1
        let generation = loadGeneration
        let snapshotGame = selectedGame
        let snapshotSegment = selectedSegment

        if reason == .initial || allTournaments.isEmpty {
            state = .loading
        }

        nextPageToLoad = 1
        hasMorePages = true
        isLoadingNextPage = false
        allTournaments = []

        async let tournaments: TournamentsListPage = interactor.fetchTournamentsPage(
            game: snapshotGame,
            segment: snapshotSegment,
            page: 1,
            pageSize: Constants.pageSize
        )
        async let live: [Match] = interactor.fetchLiveMatches(game: snapshotGame)

        do {
            let page = try await tournaments
            let liveResult = await live

            guard generation == loadGeneration,
                  snapshotGame == selectedGame,
                  snapshotSegment == selectedSegment else { return }

            allTournaments = page.tournaments
            hasMorePages = page.hasMore
            nextPageToLoad = 2
            applyLoadedState()
            updateLiveMatches(liveResult, for: snapshotGame)
            hasLoadedInitial = true
        } catch is CancellationError {
            return
        } catch {
            guard generation == loadGeneration,
                  snapshotGame == selectedGame,
                  snapshotSegment == selectedSegment else { return }
            applyErrorState(for: error)
        }
    }

    func loadNextPage() {
        guard hasMorePages, !isLoadingNextPage else { return }
        isLoadingNextPage = true
        pageGeneration &+= 1
        let generation = pageGeneration
        let pageNumber = nextPageToLoad
        let snapshotGame = selectedGame
        let snapshotSegment = selectedSegment

        paginationTask?.cancel()
        paginationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await self.interactor.fetchTournamentsPage(
                    game: snapshotGame,
                    segment: snapshotSegment,
                    page: pageNumber,
                    pageSize: Constants.pageSize
                )
                await MainActor.run {
                    guard generation == self.pageGeneration,
                          snapshotGame == self.selectedGame,
                          snapshotSegment == self.selectedSegment else { return }
                    self.applyNextPage(page, pageNumber: pageNumber)
                }
            } catch {
                await MainActor.run {
                    guard generation == self.pageGeneration else { return }
                    self.isLoadingNextPage = false
                    self.hasMorePages = false
                }
            }
        }
    }

    func applyNextPage(_ page: TournamentsListPage, pageNumber: Int) {
        let existingIds = Set(allTournaments.map(\.id))
        let unique = page.tournaments.filter { !existingIds.contains($0.id) }
        if !unique.isEmpty {
            allTournaments.append(contentsOf: unique)
            applyLoadedState()
        }
        hasMorePages = page.hasMore && !unique.isEmpty
        nextPageToLoad = pageNumber + 1
        isLoadingNextPage = false
        analytics.report(.listScrolledToBottom(page: pageNumber))
    }

    func applyLoadedState() {
        if allTournaments.isEmpty {
            let kind: TournamentsEmptyStateView.Kind = emptyKind(for: selectedSegment)
            state = .empty(kind: kind)
        } else {
            let groups = TournamentSeriesGroup.makeGroups(from: allTournaments)
            // Sort by tier rank ascending (S → A → B → C → D → nil) so the
            // top of the list is always the most prestigious tournaments.
            // The sort is stable (Swift's `sorted` is documented stable),
            // so within the same tier the server's `begin_at` order is
            // preserved — chronological for running/upcoming, reverse-
            // chronological for past. nil-tier (amateur / unranked) lands
            // at the bottom via `Int.max`.
            //
            // Trade-off: when a later pagination page brings a higher-tier
            // tournament that wasn't on page 1, the list re-orders and
            // the user sees a visual shift. In practice the first page
            // (size 30) almost always contains all S/A tournaments because
            // PandaScore returns them sorted by `begin_at` (the upcoming
            // calendar is finite). Acceptable for MVP; if it becomes an
            // issue, switch to "sort on initial only, append at tail for
            // subsequent pages".
            let sorted = groups.sorted { lhs, rhs in
                let l = lhs.tier?.rank ?? Int.max
                let r = rhs.tier?.rank ?? Int.max
                return l < r
            }
            state = .loaded(groups: sorted)
        }
    }

    func applyErrorState(for error: Error) {
        let kind = errorKind(for: error)
        state = .error(kind: kind)
        analytics.report(.errorShown(screen: .list, kind: errorKindToAnalytics(kind)))
    }

    func refreshLiveMatches() async {
        let snapshotGame = selectedGame
        let result = await interactor.fetchLiveMatches(game: snapshotGame)
        guard snapshotGame == selectedGame else { return }
        updateLiveMatches(result, for: snapshotGame)
    }

    func updateLiveMatches(_ matches: [Match], for game: Game) {
        let onlyRunning = matches.filter { $0.status == .running }
        liveMatches = onlyRunning
        if liveStripShownCount != onlyRunning.count {
            liveStripShownCount = onlyRunning.count
            analytics.report(.liveStripShown(count: onlyRunning.count, game: game))
        }
    }

    func emptyKind(for segment: TournamentSegment) -> TournamentsEmptyStateView.Kind {
        switch segment {
        case .running: .emptyRunning
        case .upcoming: .emptyUpcoming
        case .past: .emptyPast
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
