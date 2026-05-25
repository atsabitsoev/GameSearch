//
//  MatchDetailsViewModel.swift
//  GameSearch
//
//  Drives `MatchDetailsView`. Owns:
//  - the primary match payload state,
//  - a separate best-effort `tournamentContext` state used by the
//    header caption ("PGL Major · Group Stage"). When the secondary
//    fetch fails or the match has no `tournamentId`, the caption is
//    silently omitted — never failing the screen.
//
//  All async work is generation-tracked so refresh/retry can cancel
//  stale fetches without a Combine pipeline.
//

import Foundation

@MainActor
final class MatchDetailsViewModel: MatchDetailsViewModelProtocol {

    // MARK: - Published

    @Published private(set) var state: MatchDetailsState = .loading
    @Published private(set) var tournamentContext: MatchDetailsTournamentContextState = .idle

    // MARK: - Identity

    let matchId: MatchId

    // MARK: - Dependencies

    private let interactor: MatchDetailsInteractorProtocol
    private let analytics: TournamentsAnalyticsReporting

    // MARK: - State (private)

    private var loadTask: Task<Void, Never>?
    private var tournamentTask: Task<Void, Never>?

    private var loadGeneration: UInt64 = 0
    private var tournamentGeneration: UInt64 = 0

    /// Tournament id we already kicked off a context-fetch for. Prevents
    /// a second fetch on the same match payload (refresh resets it).
    private var tournamentContextRequestedFor: TournamentId?

    /// Tracks whether `match_has_streams_count` was already reported for
    /// the currently-loaded match payload — we report it once per load,
    /// not on every state mutation.
    private var streamsCountReported: Bool = false

    // MARK: - Init

    init(
        matchId: MatchId,
        interactor: MatchDetailsInteractorProtocol,
        analytics: TournamentsAnalyticsReporting = TournamentsAnalytics.shared
    ) {
        self.matchId = matchId
        self.interactor = interactor
        self.analytics = analytics
    }

    deinit {
        loadTask?.cancel()
        tournamentTask?.cancel()
    }

    // MARK: - Intents

    func onAppear() async {
        if case .loaded = state { return }
        await loadMatch()
    }

    func onPullToRefresh() async {
        analytics.report(.pulledToRefresh(screen: .match))
        let tournamentId: TournamentId?
        if case .loaded(let match) = state {
            tournamentId = match.tournamentId
        } else {
            tournamentId = nil
        }
        await interactor.invalidateCache(matchId: matchId, tournamentId: tournamentId)
        tournamentContextRequestedFor = nil
        streamsCountReported = false
        await loadMatch()
    }

    func onRetry() async {
        if case .error(let kind) = state {
            analytics.report(.errorRetryTapped(screen: .match, kind: errorKindToAnalytics(kind)))
        }
        await loadMatch()
    }

    func onStreamTapped(_ stream: Stream) {
        analytics.report(.streamOpened(
            matchId: matchId,
            platform: TournamentsAnalyticsEvent.StreamPlatformAnalytics(stream.platform),
            language: stream.language.isEmpty ? "unknown" : stream.language,
            isMain: stream.main,
            isOfficial: stream.official
        ))
    }

    func onStreamOpenFailed(_ stream: Stream, reason: TournamentsAnalyticsEvent.StreamOpenFailReason) {
        analytics.report(.streamOpenFailed(
            matchId: matchId,
            platform: TournamentsAnalyticsEvent.StreamPlatformAnalytics(stream.platform),
            reason: reason
        ))
    }

    func onShareTapped() {
        guard case .loaded = state else { return }
        analytics.report(.matchShared(id: matchId))
    }

    func shareUrl() -> URL? {
        URL(string: "gamesearch://match/\(matchId)")
    }
}

// MARK: - Loading

private extension MatchDetailsViewModel {

    func loadMatch() async {
        loadGeneration &+= 1
        let generation = loadGeneration

        if case .loaded = state {
            // Keep currently-rendered data; pull-to-refresh refresh is soft.
        } else {
            state = .loading
        }

        do {
            let match = try await interactor.fetchMatch(id: matchId)
            guard generation == loadGeneration else { return }
            state = .loaded(match)
            if !streamsCountReported {
                streamsCountReported = true
                analytics.report(.matchHasStreamsCount(matchId: matchId, count: match.streams.count))
            }
            // Tournament context — best-effort, only once per loaded match.
            if tournamentContextRequestedFor != match.tournamentId {
                tournamentContextRequestedFor = match.tournamentId
                tournamentTask?.cancel()
                tournamentTask = Task { [weak self] in
                    await self?.loadTournamentContext(tournamentId: match.tournamentId)
                }
            }
        } catch {
            if error.isCancellation { return }
            guard generation == loadGeneration else { return }
            let kind = errorKind(for: error)
            state = .error(kind: kind)
            analytics.report(.errorShown(screen: .match, kind: errorKindToAnalytics(kind)))
        }
    }

    func loadTournamentContext(tournamentId: TournamentId) async {
        tournamentGeneration &+= 1
        let generation = tournamentGeneration
        tournamentContext = .loading
        do {
            let tournament = try await interactor.fetchTournament(idOrSlug: String(tournamentId))
            guard generation == tournamentGeneration else { return }
            tournamentContext = .loaded(tournament)
        } catch {
            if error.isCancellation { return }
            guard generation == tournamentGeneration else { return }
            // Caption is enhancement — silent failure.
            tournamentContext = .unavailable
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
