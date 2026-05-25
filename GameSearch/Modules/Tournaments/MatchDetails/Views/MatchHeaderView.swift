//
//  MatchHeaderView.swift
//  GameSearch
//
//  Top hero block for `MatchDetailsView`. Layout mirrors
//  `docs/tournaments/10-screens.md`:
//      "PGL Major · Group Stage"        ← caption (from tournament context, optional)
//      [Logo]   BoX/LIVE/score   [Logo]
//      Team A   ── center ──     Team B
//                 12:00 / Сегодня в 12:00 / Завтра в 15:00
//
//  Behaviour for each MatchStatus:
//      - not_started / postponed: scheduled time shown big in the center
//      - running: score + ●LIVE badge
//      - finished: score with winner highlighted in EAColor.yellow
//      - canceled: «Отменён» pill instead of score
//

import SwiftUI

struct MatchHeaderView: View {
    let match: Match
    /// Optional tournament context — when present, renders the caption
    /// line "<league> · <stage>" above the teams block.
    let tournamentContext: Tournament?

    var body: some View {
        VStack(spacing: 14) {
            captionLine
            teamsBlock
            footerLine
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }
}

// MARK: - Caption

private extension MatchHeaderView {

    @ViewBuilder
    var captionLine: some View {
        if let text = captionText {
            Text(text)
                .font(EAFont.description)
                .foregroundStyle(EAColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }

    var captionText: String? {
        guard let context = tournamentContext else { return nil }
        let league = context.league.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let stage = context.name.trimmingCharacters(in: .whitespacesAndNewlines)
        switch (league.isEmpty, stage.isEmpty) {
        case (false, false): return "\(league) · \(stage)"
        case (false, true): return league
        case (true, false): return stage
        case (true, true): return nil
        }
    }
}

// MARK: - Teams block

private extension MatchHeaderView {

    var teamsBlock: some View {
        HStack(alignment: .center, spacing: 12) {
            teamColumn(side: .left)
            centerColumn
            teamColumn(side: .right)
        }
    }

    enum Side { case left, right }

    func teamColumn(side: Side) -> some View {
        let opponent = opponent(at: side)
        let team = opponent?.team
        let name = team?.name ?? team?.acronym ?? "TBD"
        let isWinner = opponent.flatMap { opp in
            match.winnerId.map { $0 == opp.team.id }
        } ?? false
        let score = opponent.flatMap { opp in
            match.results.first(where: { $0.teamId == opp.team.id })?.score
        }
        return VStack(spacing: 10) {
            TeamLogo(team: team, size: 72)
            Text(name)
                .font(EAFont.smallTitle)
                .foregroundStyle(isWinner ? EAColor.yellow : EAColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            scoreText(score: score, isWinner: isWinner)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func scoreText(score: Int?, isWinner: Bool) -> some View {
        switch match.status {
        case .running, .finished:
            Text(score.map(String.init) ?? "—")
                .font(EAFont.title)
                .foregroundStyle(isWinner ? EAColor.yellow : EAColor.textPrimary)
        case .notStarted, .postponed, .canceled:
            EmptyView()
        }
    }
}

// MARK: - Center column (BoX / status / time)

private extension MatchHeaderView {

    var centerColumn: some View {
        VStack(spacing: 8) {
            Text(TournamentsStrings.bestOf(match.numberOfGames))
                .font(EAFont.infoBold)
                .foregroundStyle(EAColor.textSecondary)
            centerStatus
        }
        .frame(minWidth: 90)
    }

    @ViewBuilder
    var centerStatus: some View {
        switch match.status {
        case .running:
            LiveBadge()
        case .finished:
            Text(TournamentsStrings.matchVersusSeparator)
                .font(EAFont.infoBig)
                .foregroundStyle(EAColor.textSecondary)
        case .notStarted, .postponed:
            // Show scheduled time prominently when no score yet.
            if let date = match.scheduledAt ?? match.beginAt {
                Text(MatchTimeFormatter.clock(date))
                    .font(EAFont.header)
                    .foregroundStyle(EAColor.textPrimary)
            } else {
                Text(TournamentsStrings.matchVersusSeparator)
                    .font(EAFont.infoBig)
                    .foregroundStyle(EAColor.textSecondary)
            }
        case .canceled:
            statusPill(text: TournamentsStrings.matchStatusCanceled, color: EAColor.textSecondary)
        }
    }

    func statusPill(text: String, color: Color) -> some View {
        Text(text)
            .font(EAFont.infoSmall)
            .fontWeight(.bold)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(color.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(color.opacity(0.55), lineWidth: 1)
            )
    }
}

// MARK: - Footer

private extension MatchHeaderView {

    @ViewBuilder
    var footerLine: some View {
        if let text = footerText {
            Text(text)
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    var footerText: String? {
        switch match.status {
        case .notStarted, .postponed:
            return MatchTimeFormatter.upcoming(match.scheduledAt ?? match.beginAt)
        case .running:
            // Header already shows ●LIVE; footer adds the start time only.
            guard let start = match.beginAt ?? match.scheduledAt else { return nil }
            return MatchTimeFormatter.clock(start)
        case .finished:
            return MatchTimeFormatter.finished(match.endAt ?? match.beginAt)
        case .canceled:
            return nil
        }
    }
}

// MARK: - Helpers

private extension MatchHeaderView {
    func opponent(at side: Side) -> Match.Opponent? {
        switch side {
        case .left: return match.opponents.first
        case .right: return match.opponents.dropFirst().first
        }
    }
}

// MARK: - Preview

#Preview {
    func team(_ id: Int, _ name: String, _ acronym: String) -> Team {
        Team(id: id, name: name, slug: name.lowercased(), acronym: acronym,
             location: nil, imageUrl: nil, currentGame: .cs2, players: nil, modifiedAt: nil)
    }
    let faze = team(411, "FaZe Clan", "FAZE")
    let navi = team(412, "Natus Vincere", "NAVI")

    func match(_ id: Int, status: MatchStatus, scores: (Int, Int)?, winner: Int?) -> Match {
        Match(
            id: id, name: "FaZe vs NaVi", status: status, matchType: .bestOf,
            numberOfGames: 5,
            scheduledAt: Date().addingTimeInterval(3600),
            beginAt: Date(),
            endAt: status == .finished ? Date() : nil,
            draw: false, forfeit: false,
            tournamentId: 100, leagueId: 1, game: .cs2,
            opponents: [Match.Opponent(team: faze), Match.Opponent(team: navi)],
            results: scores.map { [
                Match.MatchResult(teamId: 411, score: $0.0),
                Match.MatchResult(teamId: 412, score: $0.1)
            ] } ?? [],
            games: [], streams: [], winnerId: winner
        )
    }

    let league = League(id: 1, name: "PGL", slug: "pgl", imageUrl: nil)
    let serie = Serie(id: 1, name: "Major Copenhagen", fullName: nil, year: 2026, season: nil)
    let context = Tournament(
        id: 100, slug: "playoffs", name: "Playoffs", tier: .s, game: .cs2,
        league: league, serie: serie, beginAt: nil, endAt: nil,
        prizepool: nil, country: nil, region: nil, liveSupported: true,
        modifiedAt: nil, matches: nil, participants: nil
    )

    return ScrollView {
        VStack(spacing: 20) {
            MatchHeaderView(
                match: match(1, status: .running, scores: (1, 0), winner: nil),
                tournamentContext: context
            )
            MatchHeaderView(
                match: match(2, status: .notStarted, scores: nil, winner: nil),
                tournamentContext: context
            )
            MatchHeaderView(
                match: match(3, status: .finished, scores: (2, 1), winner: 411),
                tournamentContext: context
            )
            MatchHeaderView(
                match: match(4, status: .canceled, scores: nil, winner: nil),
                tournamentContext: nil
            )
        }
        .padding()
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
