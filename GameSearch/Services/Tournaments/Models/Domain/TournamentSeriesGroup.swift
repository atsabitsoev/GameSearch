//
//  TournamentSeriesGroup.swift
//  GameSearch
//
//  PandaScore returns each *stage* of a series as a separate `Tournament`
//  (Group A, Group B, Playoffs). For lists we want to render one card per
//  series instead, with aggregated dates, prize pool, and a chained list of
//  stage names.
//
//  This aggregate is computed on the client from `[Tournament]` returned by
//  the service — no extra network calls needed.
//

import Foundation

struct TournamentSeriesGroup: Identifiable, Hashable, Sendable {

    // MARK: - Identity

    /// Series id from PandaScore — stable across stages and pages.
    var id: SerieId { serie.id }

    // MARK: - Shared fields (taken from the first stage; identical across stages of the same series)

    let serie: Serie
    let league: League
    let game: Game

    // MARK: - Stages

    /// Stages sorted by `begin_at` ascending. The earliest stage is first,
    /// the latest (usually Playoffs / Grand Final) is last.
    let stages: [Tournament]

    // MARK: - Aggregates

    /// Earliest stage start.
    var beginAt: Date? { stages.compactMap(\.beginAt).min() }

    /// Latest stage end.
    var endAt: Date? { stages.compactMap(\.endAt).max() }

    /// First non-nil prize pool across stages. PandaScore typically attaches
    /// the full prize pool only to the Playoffs/Final stage.
    var prizepool: Prizepool? {
        stages.compactMap(\.prizepool).first
    }

    /// Highest tier across stages (S > A > B > C > D). Stages of the same
    /// series almost always carry the same tier — this is just a safe net.
    var tier: Tier? {
        stages.compactMap(\.tier).min(by: { Self.tierRank($0) < Self.tierRank($1) })
    }

    /// `true` if at least one stage is currently live.
    var isLive: Bool { stages.contains(where: \.isLive) }

    /// Stage used for navigation — the most "interesting" one available.
    /// Order of preference: any currently running > the last by begin date
    /// (usually Playoffs) > the first stage. Use the segment-aware overload
    /// `representativeStage(for:)` from list contexts so an "upcoming"
    /// series opens on its first stage instead of the final one.
    var representativeStage: Tournament {
        if let live = stages.first(where: \.isLive) { return live }
        return stages.last ?? stages[0]
    }

    /// Context-aware target stage for tap navigation. Live always wins
    /// regardless of segment; otherwise we bias by the user's current
    /// segment so the chosen stage matches their intent.
    func representativeStage(for segment: TournamentSegment) -> Tournament {
        if let live = stages.first(where: \.isLive) { return live }
        switch segment {
        case .running:
            // Series is "running" overall but no individual stage is live.
            // Prefer the next stage about to start; fall back to the latest.
            let now = Date()
            if let next = stages.first(where: { ($0.beginAt ?? .distantPast) >= now }) {
                return next
            }
            return stages.last ?? stages[0]
        case .upcoming:
            // Whole series hasn't started: open the earliest stage.
            return stages.first ?? stages[0]
        case .past:
            // Series is finished: open the final stage (Playoffs).
            return stages.last ?? stages[0]
        }
    }

    /// Stage names joined for the subtitle row, e.g. `"Group A · Group B · Playoffs"`.
    var stageNamesJoined: String {
        stages.map(\.name).joined(separator: " · ")
    }

    // MARK: - Title

    /// Display title for cards — delegates to representative stage which
    /// already knows how to format league/serie fallbacks.
    var displayTitle: String {
        representativeStage.displayListTitle
    }
}

// MARK: - Grouping factory

extension TournamentSeriesGroup {

    /// Groups the input array of tournaments by `serie.id`, preserving the
    /// order of first appearance. Stages inside each group are sorted by
    /// `begin_at` ascending so the rendered subtitle reads
    /// `"Group A · Group B · Playoffs"`.
    static func makeGroups(from tournaments: [Tournament]) -> [TournamentSeriesGroup] {
        var orderedKeys: [SerieId] = []
        var buckets: [SerieId: [Tournament]] = [:]

        for tournament in tournaments {
            let key = tournament.serie.id
            if buckets[key] == nil {
                orderedKeys.append(key)
                buckets[key] = [tournament]
            } else {
                buckets[key]?.append(tournament)
            }
        }

        return orderedKeys.compactMap { key -> TournamentSeriesGroup? in
            guard let stages = buckets[key], let head = stages.first else { return nil }
            let sortedStages = stages.sorted { lhs, rhs in
                switch (lhs.beginAt, rhs.beginAt) {
                case let (l?, r?) where l != r: return l < r
                case (nil, _?): return false
                case (_?, nil): return true
                default:
                    // Same begin_at (typical for sibling groups like Group A/B):
                    // fall back to name, then id, so the subtitle reads in a
                    // stable, alphabetical order.
                    if lhs.name != rhs.name { return lhs.name < rhs.name }
                    return lhs.id < rhs.id
                }
            }
            return TournamentSeriesGroup(
                serie: head.serie,
                league: head.league,
                game: head.game,
                stages: sortedStages
            )
        }
    }

    private static func tierRank(_ tier: Tier) -> Int {
        switch tier {
        case .s: 0
        case .a: 1
        case .b: 2
        case .c: 3
        case .d: 4
        }
    }
}
