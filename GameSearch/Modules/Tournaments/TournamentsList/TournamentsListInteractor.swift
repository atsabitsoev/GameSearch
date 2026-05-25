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
        // `hasMore` must be computed on the original page size BEFORE we
        // append sibling stages — otherwise we'd think every page is "full".
        let hasMore = items.count >= pageSize
        let enriched = await enrichWithSiblingStages(items)
        return TournamentsListPage(tournaments: enriched, hasMore: hasMore)
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
        // Sibling stages of every series we touched in this segment may
        // carry the prize pool we want to surface on a list card. Drop the
        // series cache too so a manual refresh re-pulls the truth.
        await cache.invalidate(prefix: "series:tournaments:")
    }
}

// MARK: - Sibling stages enrichment

private extension TournamentsListInteractor {

    /// PandaScore typically attaches the prize pool only to the Playoffs/Final
    /// stage of a series. When the segment endpoint (e.g. `/tournaments/running`)
    /// returns only an earlier stage (e.g. Group Stage), the resulting series
    /// card ends up without a prize pool even though one is attached to a
    /// sibling stage in the same series.
    ///
    /// This helper fans out — once per series that is missing a prize pool —
    /// a `/series/<id>/tournaments` request (cached for 1 hour by the
    /// service) and folds the missing stages back into the page. Stages
    /// returned by the original endpoint are kept as-is; new stages from
    /// siblings are appended at the end. Duplicate ids are filtered.
    ///
    /// Failures are swallowed silently — the list must keep rendering even
    /// if a single series request fails.
    func enrichWithSiblingStages(_ items: [Tournament]) async -> [Tournament] {
        let groupedBySerie = Dictionary(grouping: items, by: { $0.serie.id })
        let serieIdsMissingPrizepool: [SerieId] = groupedBySerie
            .filter { _, stages in stages.allSatisfy { $0.prizepool == nil } }
            .map { $0.key }

        guard !serieIdsMissingPrizepool.isEmpty else { return items }

        let siblings = await fetchSiblingStages(for: serieIdsMissingPrizepool)
        guard !siblings.isEmpty else { return items }

        var seen = Set(items.map(\.id))
        var enriched = items
        for stage in siblings where !seen.contains(stage.id) {
            enriched.append(stage)
            seen.insert(stage.id)
        }
        return enriched
    }

    func fetchSiblingStages(for serieIds: [SerieId]) async -> [Tournament] {
        await withTaskGroup(of: [Tournament].self) { group in
            for serieId in serieIds {
                group.addTask { [weak self] in
                    guard let self else { return [] }
                    do {
                        return try await self.tournamentsService
                            .fetchSeriesTournaments(serieId: serieId)
                    } catch {
                        self.log.error("Sibling stages fetch failed for serie=\(serieId, privacy: .public): \(String(describing: error), privacy: .public)")
                        return []
                    }
                }
            }
            var collected: [Tournament] = []
            for await stages in group {
                collected.append(contentsOf: stages)
            }
            return collected
        }
    }
}
