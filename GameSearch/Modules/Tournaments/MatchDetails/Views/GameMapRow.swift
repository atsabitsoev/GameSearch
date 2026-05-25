//
//  GameMapRow.swift
//  GameSearch
//
//  One row inside `MatchGamesList`. Renders position, map name (CS2) or
//  "Игра N" (Dota 2), per-game status (●LIVE / finished / not started),
//  and the winning team for finished games. Per-game score is NOT
//  rendered — PandaScore Free returns only `winner.id` per game (no
//  rounds-won field), so showing a synthesized score would be
//  misleading. Match-level series score lives in the header.
//

import SwiftUI

struct GameMapRow: View {
    let position: Int
    let game: Match.PlayedGame
    let opponents: [Match.Opponent]
    let videogame: Game

    var body: some View {
        HStack(spacing: 12) {
            positionLabel
            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(EAFont.smallTitle)
                    .foregroundStyle(EAColor.textPrimary)
                    .lineLimit(1)
                if let winnerName {
                    Text(winnerName)
                        .font(EAFont.description)
                        .foregroundStyle(EAColor.yellow)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            trailing
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }
}

private extension GameMapRow {

    var positionLabel: some View {
        Text("\(position)")
            .font(EAFont.infoBold)
            .foregroundStyle(EAColor.textSecondary)
            .frame(width: 20, alignment: .leading)
    }

    var displayName: String {
        if let map = game.mapName, !map.isEmpty {
            return map
        }
        switch videogame {
        case .cs2: return "Карта \(position)"
        case .dota2: return "Игра \(position)"
        }
    }

    var winnerName: String? {
        guard game.status == .finished, let winnerId = game.winnerId else { return nil }
        return opponents.first { $0.team.id == winnerId }?.team.name
    }

    @ViewBuilder
    var trailing: some View {
        switch game.status {
        case .running:
            LiveBadge(compact: false)
        case .finished:
            // Winner is already highlighted under the map name; trailing
            // stays empty for finished rows to avoid duplication.
            EmptyView()
        case .notStarted, .postponed, .canceled:
            Text(TournamentsStrings.matchMapNotStarted)
                .font(EAFont.description)
                .foregroundStyle(EAColor.textSecondary)
        }
    }
}
