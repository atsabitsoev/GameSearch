//
//  MatchesTab.swift
//  GameSearch
//
//  "Матчи" tab of `TournamentDetailsView`. Matches are loaded via a
//  dedicated `MatchesService.fetchTournamentMatches(tournamentId:)`
//  call (NOT from `tournament.matches` — inline matches inside
//  `/tournaments/{id}` are stripped of opponents/results and cannot be
//  rendered as a row). The tab therefore has its own lazy state owned
//  by the VM.
//
//  Sort order: live → upcoming (chronological) → finished (most recent
//  first). Section title is the stage name from the parent tournament
//  ("Group A", "Playoffs", …).
//

import SwiftUI

struct MatchesTab: View {
    let state: TournamentDetailsMatchesState
    let stageName: String
    let onTapMatch: (Match) -> Void
    let onRetry: () -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            loadingView
        case .loaded(let matches):
            content(matches)
        case .empty:
            TournamentsEmptyStateView(kind: .emptyUpcoming)
        case .error(let kind):
            TournamentsEmptyStateView(kind: kind, onRetry: onRetry)
        }
    }
}

private extension MatchesTab {

    var trimmedStageName: String {
        stageName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var loadingView: some View {
        VStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { _ in
                MatchRowSkeleton()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    func content(_ matches: [Match]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if !trimmedStageName.isEmpty {
                Text(trimmedStageName)
                    .font(EAFont.header)
                    .foregroundStyle(EAColor.textPrimary)
                    .padding(.horizontal, 16)
            }
            LazyVStack(spacing: 12) {
                ForEach(sortedMatches(matches)) { match in
                    Button {
                        onTapMatch(match)
                    } label: {
                        MatchRowView(match: match)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    func sortedMatches(_ raw: [Match]) -> [Match] {
        let live = raw.filter { $0.status == .running }
        let upcoming = raw
            .filter { $0.status == .notStarted || $0.status == .postponed }
            .sorted(by: { lhs, rhs in
                (lhs.scheduledAt ?? lhs.beginAt ?? .distantFuture)
                    < (rhs.scheduledAt ?? rhs.beginAt ?? .distantFuture)
            })
        let finished = raw
            .filter { $0.status == .finished || $0.status == .canceled }
            .sorted(by: { lhs, rhs in
                (lhs.endAt ?? lhs.beginAt ?? .distantPast)
                    > (rhs.endAt ?? rhs.beginAt ?? .distantPast)
            })
        return live + upcoming + finished
    }
}

// MARK: - Row

struct MatchRowView: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            teamLine(side: .left)
            HStack(spacing: 8) {
                Text("vs")
                    .font(EAFont.infoSmall)
                    .foregroundStyle(EAColor.textSecondary)
                statusBadge
                Spacer(minLength: 0)
            }
            teamLine(side: .right)
            footerLine
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(match.isLive ? Color.red.opacity(0.35) : Color.clear, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityLabel(Text(accessibilityLabel))
    }
}

private extension MatchRowView {

    enum Side { case left, right }

    func teamLine(side: Side) -> some View {
        let opponent = opponent(at: side)
        let name = opponent?.team.name ?? opponent?.team.acronym ?? "TBD"
        let score = opponent.flatMap { opp in
            match.results.first(where: { $0.teamId == opp.team.id })?.score
        }
        let isWinner = opponent.flatMap { opp in
            match.winnerId.map { $0 == opp.team.id }
        } ?? false
        return HStack(spacing: 10) {
            TeamLogo(team: opponent?.team, size: 28)
            Text(name)
                .font(EAFont.smallTitle)
                .foregroundStyle(isWinner ? EAColor.yellow : EAColor.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 0)
            scoreText(score: score, isWinner: isWinner)
        }
    }

    @ViewBuilder
    func scoreText(score: Int?, isWinner: Bool) -> some View {
        switch match.status {
        case .notStarted, .postponed, .canceled:
            EmptyView()
        case .running, .finished:
            Text(score.map(String.init) ?? "—")
                .font(EAFont.infoBold)
                .foregroundStyle(isWinner ? EAColor.yellow : EAColor.textPrimary)
        }
    }

    @ViewBuilder
    var statusBadge: some View {
        switch match.status {
        case .running: LiveBadge(compact: true)
        case .canceled:
            statusPill(text: TournamentsStrings.matchStatusCanceled, color: EAColor.textSecondary)
        case .postponed:
            statusPill(text: TournamentsStrings.matchStatusPostponed, color: EAColor.info2)
        case .notStarted, .finished:
            EmptyView()
        }
    }

    func statusPill(text: String, color: Color) -> some View {
        Text(text)
            .font(EAFont.infoSmall)
            .fontWeight(.bold)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(color.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(color.opacity(0.55), lineWidth: 1)
            )
    }

    var footerLine: some View {
        HStack(spacing: 6) {
            Text(TournamentsStrings.bestOf(match.numberOfGames))
                .font(EAFont.description)
                .foregroundStyle(EAColor.textSecondary)
            if let timeText {
                Text("·")
                    .font(EAFont.description)
                    .foregroundStyle(EAColor.textSecondary)
                Text(timeText)
                    .font(EAFont.description)
                    .foregroundStyle(EAColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
    }

    var timeText: String? {
        switch match.status {
        case .notStarted, .postponed:
            return MatchTimeFormatter.upcoming(match.scheduledAt ?? match.beginAt)
        case .running:
            return MatchTimeFormatter.clock(match.beginAt ?? match.scheduledAt)
        case .finished:
            return MatchTimeFormatter.finished(match.endAt ?? match.beginAt)
        case .canceled:
            return nil
        }
    }

    func opponent(at side: Side) -> Match.Opponent? {
        switch side {
        case .left: return match.opponents.first
        case .right: return match.opponents.dropFirst().first
        }
    }

    var accessibilityLabel: String {
        let left = match.opponents.first?.team.name ?? "TBD"
        let right = match.opponents.dropFirst().first?.team.name ?? "TBD"
        return "\(left) против \(right), \(TournamentsStrings.bestOf(match.numberOfGames))"
    }
}

// MARK: - Skeleton

private struct MatchRowSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(EAColor.secondaryBackground.opacity(0.6))
                    .frame(width: 28, height: 28)
                SkeletonRectangle(width: 100, height: 14)
                Spacer()
                SkeletonRectangle(width: 24, height: 14)
            }
            SkeletonRectangle(width: 40, height: 10)
            HStack(spacing: 10) {
                Circle()
                    .fill(EAColor.secondaryBackground.opacity(0.6))
                    .frame(width: 28, height: 28)
                SkeletonRectangle(width: 120, height: 14)
                Spacer()
                SkeletonRectangle(width: 24, height: 14)
            }
            SkeletonRectangle(width: 140, height: 12)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }
}

#Preview {
    let faze = Team(id: 1, name: "FaZe Clan", slug: "faze", acronym: "FaZe",
                    location: nil, imageUrl: nil, currentGame: .cs2, players: nil, modifiedAt: nil)
    let navi = Team(id: 2, name: "Natus Vincere", slug: "navi", acronym: "NaVi",
                    location: nil, imageUrl: nil, currentGame: .cs2, players: nil, modifiedAt: nil)

    func match(id: Int, status: MatchStatus, scores: (Int, Int)?, winner: Int?) -> Match {
        Match(
            id: id, name: "FaZe vs NaVi", status: status, matchType: .bestOf,
            numberOfGames: 5, scheduledAt: Date(), beginAt: Date(),
            endAt: status == .finished ? Date() : nil,
            draw: false, forfeit: false,
            tournamentId: 100, leagueId: 1, game: .cs2,
            opponents: [Match.Opponent(team: faze), Match.Opponent(team: navi)],
            results: scores.map { [
                Match.MatchResult(teamId: 1, score: $0.0),
                Match.MatchResult(teamId: 2, score: $0.1)
            ] } ?? [],
            games: [], streams: [], winnerId: winner
        )
    }

    let matches: [Match] = [
        match(id: 1, status: .running, scores: (1, 0), winner: nil),
        match(id: 2, status: .notStarted, scores: nil, winner: nil),
        match(id: 3, status: .finished, scores: (2, 1), winner: 1),
        match(id: 4, status: .canceled, scores: nil, winner: nil)
    ]

    return ScrollView {
        VStack(spacing: 32) {
            MatchesTab(state: .loaded(matches), stageName: "Playoffs",
                       onTapMatch: { _ in }, onRetry: {})
            MatchesTab(state: .loading, stageName: "Playoffs",
                       onTapMatch: { _ in }, onRetry: {})
            MatchesTab(state: .empty, stageName: "Playoffs",
                       onTapMatch: { _ in }, onRetry: {})
        }
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
