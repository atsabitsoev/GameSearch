//
//  MatchGamesList.swift
//  GameSearch
//
//  "Карты" / "Игры" section of `MatchDetailsView`. Renders the played
//  games sorted by position, padded out with placeholder rows up to
//  `match.numberOfGames` so a BO5 with 2 played games still shows 5
//  slots (matches the wireframe in `docs/tournaments/10-screens.md`).
//
//  Hidden entirely when `numberOfGames <= 1` (single-game match — no
//  point listing one row).
//

import SwiftUI

struct MatchGamesList: View {
    let match: Match

    var body: some View {
        if !shouldRender { EmptyView() } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(sectionTitle)
                    .font(EAFont.header)
                    .foregroundStyle(EAColor.textPrimary)
                    .padding(.horizontal, 16)
                VStack(spacing: 6) {
                    ForEach(rows, id: \.position) { row in
                        GameMapRow(
                            position: row.position,
                            game: row.game,
                            opponents: match.opponents,
                            videogame: match.game
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private extension MatchGamesList {

    var shouldRender: Bool {
        match.numberOfGames > 1
    }

    var sectionTitle: String {
        switch match.game {
        case .cs2: return TournamentsStrings.matchSectionMaps
        case .dota2: return TournamentsStrings.matchSectionGames
        }
    }

    struct Row: Hashable {
        let position: Int
        let game: Match.PlayedGame
    }

    /// Build a position-indexed list `[1, 2, …, numberOfGames]`. Played
    /// games slot into their actual `position`; remaining slots get a
    /// synthetic placeholder `PlayedGame` with `.notStarted` so the row
    /// still renders.
    var rows: [Row] {
        // PandaScore should give us unique positions per game, but be
        // defensive: if two games share the same position (data bug),
        // pick the one with the latest status update (finished > running
        // > not_started) rather than crashing via
        // `Dictionary(uniqueKeysWithValues:)`.
        let actualByPosition = Dictionary(
            match.games.map { ($0.position, $0) },
            uniquingKeysWith: { lhs, rhs in
                rhs.status.priority >= lhs.status.priority ? rhs : lhs
            }
        )
        let count = max(match.numberOfGames, match.games.map(\.position).max() ?? 0)
        guard count > 0 else { return [] }
        return (1...count).map { position in
            if let game = actualByPosition[position] {
                return Row(position: position, game: game)
            }
            return Row(
                position: position,
                game: Match.PlayedGame(
                    id: -position,
                    position: position,
                    status: .notStarted,
                    mapName: nil,
                    winnerId: nil,
                    beginAt: nil,
                    endAt: nil,
                    length: nil,
                    videoUrl: nil
                )
            )
        }
    }
}

// MARK: - Status priority

private extension MatchStatus {
    /// Ordering used when collapsing duplicate-position games in
    /// `MatchGamesList.rows`. Higher = more "final" / authoritative.
    var priority: Int {
        switch self {
        case .notStarted, .postponed: 0
        case .running: 1
        case .canceled: 2
        case .finished: 3
        }
    }
}

#Preview {
    func team(_ id: Int, _ name: String) -> Team {
        Team(id: id, name: name, slug: name.lowercased(), acronym: nil,
             location: nil, imageUrl: nil, currentGame: .cs2, players: nil, modifiedAt: nil)
    }
    let faze = team(411, "FaZe")
    let navi = team(412, "NaVi")
    let games: [Match.PlayedGame] = [
        Match.PlayedGame(id: 1, position: 1, status: .finished, mapName: "Mirage",
                         winnerId: 411, beginAt: Date(), endAt: Date(), length: 2700, videoUrl: nil),
        Match.PlayedGame(id: 2, position: 2, status: .running, mapName: "Inferno",
                         winnerId: nil, beginAt: Date(), endAt: nil, length: nil, videoUrl: nil)
    ]
    let match = Match(
        id: 1, name: "FaZe vs NaVi", status: .running, matchType: .bestOf,
        numberOfGames: 5, scheduledAt: nil, beginAt: Date(), endAt: nil,
        draw: false, forfeit: false, tournamentId: 1, leagueId: 1, game: .cs2,
        opponents: [Match.Opponent(team: faze), Match.Opponent(team: navi)],
        results: [], games: games, streams: [], winnerId: nil
    )
    return ScrollView {
        MatchGamesList(match: match)
            .padding(.vertical, 16)
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
