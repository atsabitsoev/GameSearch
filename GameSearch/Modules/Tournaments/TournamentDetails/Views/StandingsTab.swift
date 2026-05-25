//
//  StandingsTab.swift
//  GameSearch
//
//  "Таблица" tab of `TournamentDetailsView`. Lazy-loaded sub-state
//  owned by the VM (`standingsState`).
//
//  PandaScore's CS2 standings (both Swiss group stages and playoff
//  brackets) often return only `rank` + `team` without W/L/Points. We
//  therefore detect which columns have any data and only render those —
//  otherwise the table looks like every team has "0/0/—" which reads
//  as a bug to the user.
//

import SwiftUI

struct StandingsTab: View {
    let state: TournamentDetailsStandingsState
    let onRetry: () -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            loadingView
        case .loaded(let standings):
            content(standings)
        case .empty:
            TournamentsEmptyStateView(kind: .emptyUpcoming)
                .accessibilityLabel(Text(TournamentsStrings.standingsEmptyTitle))
        case .error(let kind):
            TournamentsEmptyStateView(kind: kind, onRetry: onRetry)
        }
    }
}

// MARK: - Layout

private extension StandingsTab {

    var loadingView: some View {
        VStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { _ in
                StandingsRowSkeleton()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    func content(_ standings: [Standing]) -> some View {
        let layout = StandingsColumnLayout(standings: standings)
        return VStack(spacing: 0) {
            header(layout: layout)
            LazyVStack(spacing: 6) {
                ForEach(standings) { standing in
                    StandingRow(standing: standing, layout: layout)
                }
            }
            .padding(.top, 6)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    func header(layout: StandingsColumnLayout) -> some View {
        HStack(spacing: 12) {
            Text(TournamentsStrings.standingsColRank)
                .frame(width: 28, alignment: .leading)
            Text(TournamentsStrings.standingsColTeam)
                .frame(maxWidth: .infinity, alignment: .leading)
            if layout.showsWins {
                Text(TournamentsStrings.standingsColWins)
                    .frame(width: 28, alignment: .trailing)
            }
            if layout.showsLosses {
                Text(TournamentsStrings.standingsColLosses)
                    .frame(width: 28, alignment: .trailing)
            }
            if layout.showsTotal {
                Text(TournamentsStrings.standingsColTotal)
                    .frame(width: 32, alignment: .trailing)
            }
            if layout.showsMaps {
                Text(TournamentsStrings.standingsColMaps)
                    .frame(width: 48, alignment: .trailing)
            }
            if layout.showsPoints {
                Text(TournamentsStrings.standingsColPoints)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .font(EAFont.description)
        .foregroundStyle(EAColor.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Column layout

/// Decides which stat columns to render based on data availability —
/// CS2 standings frequently lack W/L/Points and we want to gracefully
/// degrade to a `rank | team` only table rather than a sea of zeros.
///
/// PandaScore returns the rich shape (wins/losses/total/game_*) only
/// for **group/Swiss** standings. For playoff brackets we get just
/// `{rank, team, last_match}` and hide every stat column.
struct StandingsColumnLayout: Equatable {
    let showsWins: Bool
    let showsLosses: Bool
    let showsTotal: Bool
    let showsMaps: Bool
    let showsPoints: Bool

    init(standings: [Standing]) {
        showsWins = standings.contains { $0.wins != nil }
        showsLosses = standings.contains { $0.losses != nil }
        showsTotal = standings.contains { $0.total != nil }
        showsMaps = standings.contains { $0.gameWins != nil || $0.gameLosses != nil }
        showsPoints = standings.contains { $0.points != nil }
    }

    var hasAnyStatsColumn: Bool {
        showsWins || showsLosses || showsTotal || showsMaps || showsPoints
    }
}

// MARK: - Row

private struct StandingRow: View {
    let standing: Standing
    let layout: StandingsColumnLayout

    var body: some View {
        HStack(spacing: 12) {
            Text("\(standing.rank)")
                .font(EAFont.infoBold)
                .foregroundStyle(rankColor)
                .frame(width: 28, alignment: .leading)

            HStack(spacing: 8) {
                TeamLogo(team: standing.team, size: 24)
                Text(standing.team.name)
                    .font(EAFont.smallTitle)
                    .foregroundStyle(EAColor.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if layout.showsWins {
                statColumn(standing.wins, width: 28, color: EAColor.textPrimary)
            }
            if layout.showsLosses {
                statColumn(standing.losses, width: 28, color: EAColor.textSecondary)
            }
            if layout.showsTotal {
                statColumn(standing.total, width: 32, color: EAColor.textPrimary)
            }
            if layout.showsMaps {
                mapsColumn(width: 48)
            }
            if layout.showsPoints {
                statColumn(standing.points, width: 40, color: EAColor.yellow)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }

    func statColumn(_ value: Int?, width: CGFloat, color: Color) -> some View {
        Text(value.map(String.init) ?? "—")
            .font(EAFont.infoBold)
            .foregroundStyle(color)
            .frame(width: width, alignment: .trailing)
    }

    /// Formats map score as "7-2". Falls back to "—" if neither value
    /// is available for this row (the column is also hidden globally
    /// if no row has any map data — see `StandingsColumnLayout`).
    func mapsColumn(width: CGFloat) -> some View {
        let text: String
        switch (standing.gameWins, standing.gameLosses) {
        case (let w?, let l?):
            text = "\(w)-\(l)"
        case (let w?, nil):
            text = "\(w)-—"
        case (nil, let l?):
            text = "—-\(l)"
        case (nil, nil):
            text = "—"
        }
        return Text(text)
            .font(EAFont.infoBold)
            .foregroundStyle(EAColor.textSecondary)
            .frame(width: width, alignment: .trailing)
    }

    var rankColor: Color {
        switch standing.rank {
        case 1: return EAColor.yellow
        case 2, 3: return EAColor.purpleAccent
        default: return EAColor.textSecondary
        }
    }
}

// MARK: - Skeleton

private struct StandingsRowSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonRectangle(width: 24, height: 14)
            SkeletonRectangle(width: 24, height: 24)
            SkeletonRectangle(width: 140, height: 14)
            Spacer()
            SkeletonRectangle(width: 30, height: 14)
            SkeletonRectangle(width: 30, height: 14)
            SkeletonRectangle(width: 44, height: 14)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.5))
        )
    }
}

#Preview {
    func team(_ id: Int, _ name: String, _ acr: String) -> Team {
        Team(id: id, name: name, slug: name.lowercased(), acronym: acr,
             location: nil, imageUrl: nil, currentGame: .cs2, players: nil, modifiedAt: nil)
    }
    // Group stage with full stats (mirrors PandaScore CS2 group payload):
    let groupStage: [Standing] = [
        Standing(team: team(1, "9z", "9z"), rank: 1, wins: 3, losses: 0, ties: nil,
                 points: nil, total: 3, gameWins: 6, gameLosses: 2, gameTies: 0),
        Standing(team: team(2, "Spirit", "TS"), rank: 1, wins: 3, losses: 0, ties: nil,
                 points: nil, total: 3, gameWins: 6, gameLosses: 1, gameTies: 0),
        Standing(team: team(3, "FURIA", "FUR"), rank: 3, wins: 3, losses: 1, ties: nil,
                 points: nil, total: 4, gameWins: 7, gameLosses: 3, gameTies: 0),
        Standing(team: team(4, "MOUZ", "MOUZ"), rank: 3, wins: 3, losses: 1, ties: nil,
                 points: nil, total: 4, gameWins: 7, gameLosses: 4, gameTies: 0),
        Standing(team: team(5, "Heroic", "HER"), rank: 12, wins: 1, losses: 3, ties: nil,
                 points: nil, total: 4, gameWins: 3, gameLosses: 6, gameTies: 0),
        Standing(team: team(6, "K27", "K27"), rank: 15, wins: 0, losses: 3, ties: nil,
                 points: nil, total: 3, gameWins: 1, gameLosses: 6, gameTies: 0)
    ]
    // Playoffs — only rank + team (typical CS2 PandaScore):
    let playoffs: [Standing] = [
        Standing(team: team(1, "Spirit", "TS"), rank: 1, wins: nil, losses: nil, ties: nil,
                 points: nil, total: nil, gameWins: nil, gameLosses: nil, gameTies: nil),
        Standing(team: team(2, "MOUZ", "MOUZ"), rank: 2, wins: nil, losses: nil, ties: nil,
                 points: nil, total: nil, gameWins: nil, gameLosses: nil, gameTies: nil),
        Standing(team: team(3, "Team Falcons", "FAL"), rank: 3, wins: nil, losses: nil, ties: nil,
                 points: nil, total: nil, gameWins: nil, gameLosses: nil, gameTies: nil),
        Standing(team: team(4, "magic", "MGC"), rank: 4, wins: nil, losses: nil, ties: nil,
                 points: nil, total: nil, gameWins: nil, gameLosses: nil, gameTies: nil)
    ]
    return ScrollView {
        VStack(spacing: 32) {
            StandingsTab(state: .loaded(groupStage), onRetry: {})
            StandingsTab(state: .loaded(playoffs), onRetry: {})
            StandingsTab(state: .loading, onRetry: {})
        }
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
