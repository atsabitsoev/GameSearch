//
//  MatchStreamsList.swift
//  GameSearch
//
//  "Где смотреть" section of `MatchDetailsView`. Renders all available
//  streams sorted by main → official → others. Empty state mirrors the
//  microcopy from `12-microcopy-ru.md` ("Стримов пока нет / Появятся
//  ближе к началу"). Section is hidden entirely when the match has
//  ended (no point watching a finished match without VODs in Phase 1).
//

import SwiftUI

struct MatchStreamsList: View {
    let match: Match
    let onTapStream: (Stream) -> Void
    let onStreamOpenFailed: (Stream, TournamentsAnalyticsEvent.StreamOpenFailReason) -> Void

    var body: some View {
        if shouldRender {
            VStack(alignment: .leading, spacing: 8) {
                Text(TournamentsStrings.matchSectionStreams)
                    .font(EAFont.header)
                    .foregroundStyle(EAColor.textPrimary)
                    .padding(.horizontal, 16)
                if sortedStreams.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
        }
    }
}

// MARK: - Helpers

private extension MatchStreamsList {

    /// Show streams for upcoming and live matches; skip the section
    /// entirely for finished/canceled (no live stream to watch). We
    /// don't have VOD support in MVP.
    var shouldRender: Bool {
        switch match.status {
        case .notStarted, .running, .postponed: return true
        case .finished, .canceled: return false
        }
    }

    var sortedStreams: [Stream] {
        match.streams.sorted { lhs, rhs in
            if lhs.main != rhs.main { return lhs.main && !rhs.main }
            if lhs.official != rhs.official { return lhs.official && !rhs.official }
            return lhs.rawUrl.absoluteString < rhs.rawUrl.absoluteString
        }
    }

    var list: some View {
        VStack(spacing: 6) {
            ForEach(sortedStreams) { stream in
                StreamRow(
                    stream: stream,
                    onTap: { onTapStream(stream) },
                    onOpenFailed: { reason in onStreamOpenFailed(stream, reason) }
                )
            }
        }
        .padding(.horizontal, 16)
    }

    var emptyState: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(EAColor.secondaryBackground)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "play.tv")
                        .font(.system(size: 22))
                        .foregroundStyle(EAColor.textSecondary)
                )
            Text(TournamentsStrings.matchNoStreamsTitle)
                .font(EAFont.smallTitle)
                .foregroundStyle(EAColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(TournamentsStrings.matchNoStreamsSubtitle)
                .font(EAFont.description)
                .foregroundStyle(EAColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
}

#Preview {
    let twitch = Stream(
        id: "1", language: "ru",
        rawUrl: URL(string: "https://www.twitch.tv/maincast")!,
        embedUrl: nil, main: true, official: false,
        platform: .twitch(channel: "maincast")
    )
    let youtube = Stream(
        id: "2", language: "en",
        rawUrl: URL(string: "https://www.youtube.com/watch?v=abc123")!,
        embedUrl: nil, main: false, official: true,
        platform: .youtube(videoId: "abc123")
    )
    func team(_ id: Int, _ name: String) -> Team {
        Team(id: id, name: name, slug: name.lowercased(), acronym: nil,
             location: nil, imageUrl: nil, currentGame: .cs2, players: nil, modifiedAt: nil)
    }
    let withStreams = Match(
        id: 1, name: "FaZe vs NaVi", status: .running, matchType: .bestOf,
        numberOfGames: 5, scheduledAt: nil, beginAt: Date(), endAt: nil,
        draw: false, forfeit: false, tournamentId: 1, leagueId: 1, game: .cs2,
        opponents: [Match.Opponent(team: team(1, "FaZe")), Match.Opponent(team: team(2, "NaVi"))],
        results: [], games: [], streams: [twitch, youtube], winnerId: nil
    )
    let noStreams = Match(
        id: 2, name: "FaZe vs NaVi", status: .notStarted, matchType: .bestOf,
        numberOfGames: 3, scheduledAt: Date().addingTimeInterval(3600), beginAt: nil, endAt: nil,
        draw: false, forfeit: false, tournamentId: 1, leagueId: 1, game: .cs2,
        opponents: [], results: [], games: [], streams: [], winnerId: nil
    )
    return ScrollView {
        VStack(spacing: 24) {
            MatchStreamsList(match: withStreams,
                             onTapStream: { _ in },
                             onStreamOpenFailed: { _, _ in })
            MatchStreamsList(match: noStreams,
                             onTapStream: { _ in },
                             onStreamOpenFailed: { _, _ in })
        }
        .padding(.vertical, 16)
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
