//
//  LiveMatchChip.swift
//  GameSearch
//
//  Compact 140×120 pt card showing one live match. Used inside the
//  horizontal live strip on top of the tournaments list.
//

import SwiftUI

struct LiveMatchChip: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            LiveBadge()
            teamRow(side: .left)
            Text("vs")
                .font(EAFont.infoSmall)
                .foregroundStyle(EAColor.textSecondary)
            teamRow(side: .right)
            Spacer(minLength: 0)
            footerRow
        }
        .padding(10)
        .frame(width: 160, height: 130, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.red.opacity(0.35), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private extension LiveMatchChip {

    enum TeamSide { case left, right }

    func teamRow(side: TeamSide) -> some View {
        let opponent: Match.Opponent? = side == .left ? match.opponents.first : match.opponents.dropFirst().first
        let name = opponent?.team.acronym ?? opponent?.team.name ?? "TBD"
        let scoreValue: Int? = opponent.flatMap { opp in
            match.results.first(where: { $0.teamId == opp.team.id })?.score
        }
        return HStack(spacing: 6) {
            TeamLogo(team: opponent?.team, size: 18)
            Text(name)
                .font(EAFont.infoBold)
                .foregroundStyle(EAColor.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(scoreValue.map(String.init) ?? "—")
                .font(EAFont.infoBold)
                .foregroundStyle(EAColor.textPrimary)
        }
    }

    var footerRow: some View {
        HStack(spacing: 4) {
            Text(TournamentsStrings.bestOf(match.numberOfGames))
                .font(EAFont.infoSmall)
                .foregroundStyle(EAColor.textSecondary)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    let teamLeft = Team(
        id: 1, name: "FaZe Clan", slug: "faze", acronym: "FaZe",
        location: nil, imageUrl: nil, currentGame: .cs2, players: nil, modifiedAt: nil
    )
    let teamRight = Team(
        id: 2, name: "Natus Vincere", slug: "navi", acronym: "NaVi",
        location: nil, imageUrl: nil, currentGame: .cs2, players: nil, modifiedAt: nil
    )
    let match = Match(
        id: 1, name: "FaZe vs NaVi", status: .running, matchType: .bestOf,
        numberOfGames: 5, scheduledAt: Date(), beginAt: Date(), endAt: nil,
        draw: false, forfeit: false,
        tournamentId: 1, leagueId: 1, game: .cs2,
        opponents: [Match.Opponent(team: teamLeft), Match.Opponent(team: teamRight)],
        results: [
            Match.MatchResult(teamId: 1, score: 1),
            Match.MatchResult(teamId: 2, score: 0)
        ],
        games: [], streams: [], winnerId: nil
    )

    return HStack {
        LiveMatchChip(match: match)
        Spacer()
    }
    .padding()
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
