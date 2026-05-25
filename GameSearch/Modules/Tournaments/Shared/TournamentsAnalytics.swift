//
//  TournamentsAnalytics.swift
//  GameSearch
//
//  Type-safe wrapper around AppMetrica for the Tournaments module.
//  Mirrors the events catalogue from `docs/tournaments/13-analytics.md`.
//

import Foundation
import AnalyticsModule

// MARK: - Events

enum TournamentsAnalyticsEvent {
    case tabOpened
    case segmentSwitched(segment: TournamentSegment)
    case gameSwitched(game: Game)
    case pulledToRefresh(screen: Screen)
    case listScrolledToBottom(page: Int)

    case tournamentOpened(id: TournamentId, slug: String, fromScreen: Screen)
    case tournamentTabSwitched(id: TournamentId, tab: TournamentTab)
    case tournamentStageSwitched(fromStageId: TournamentId, toStageId: TournamentId, serieId: SerieId)
    case tournamentShared(id: TournamentId, slug: String)

    case liveStripShown(count: Int, game: Game)
    case liveStripChipTapped(matchId: MatchId, position: Int)

    case matchOpened(id: MatchId, status: MatchStatus, fromScreen: Screen)
    case matchHasStreamsCount(matchId: MatchId, count: Int)
    case matchShared(id: MatchId)

    case streamOpened(matchId: MatchId, platform: StreamPlatformAnalytics, language: String, isMain: Bool, isOfficial: Bool)
    case streamOpenFailed(matchId: MatchId, platform: StreamPlatformAnalytics, reason: StreamOpenFailReason)

    case errorShown(screen: Screen, kind: ErrorKind)
    case errorRetryTapped(screen: Screen, kind: ErrorKind)

    enum Screen: String {
        case list
        case details
        case match
        case liveStrip = "live_strip"
        case tournament
        case deeplink
        case favorites
    }

    enum TournamentTab: String {
        case matches
        case standings
        case brackets
        case participants
    }

    enum ErrorKind: String {
        case noInternet = "no_internet"
        case temporary
    }

    enum StreamPlatformAnalytics: String {
        case twitch
        case youtube
        case other
    }

    enum StreamOpenFailReason: String {
        case appNotInstalled = "app_not_installed"
        case invalidUrl = "invalid_url"
        case other
    }
}

extension TournamentsAnalyticsEvent.StreamPlatformAnalytics {
    init(_ platform: StreamPlatform) {
        switch platform {
        case .twitch: self = .twitch
        case .youtube: self = .youtube
        case .other: self = .other
        }
    }
}

extension TournamentsAnalyticsEvent {
    var name: String {
        switch self {
        case .tabOpened: "tournaments_tab_opened"
        case .segmentSwitched: "tournaments_segment_switched"
        case .gameSwitched: "tournaments_game_switched"
        case .pulledToRefresh: "tournaments_pulled_to_refresh"
        case .listScrolledToBottom: "tournaments_list_scrolled_to_bottom"
        case .tournamentOpened: "tournament_opened"
        case .tournamentTabSwitched: "tournament_tab_switched"
        case .tournamentStageSwitched: "tournament_stage_switched"
        case .tournamentShared: "tournament_shared"
        case .liveStripShown: "live_strip_shown"
        case .liveStripChipTapped: "live_strip_chip_tapped"
        case .matchOpened: "match_opened"
        case .matchHasStreamsCount: "match_has_streams_count"
        case .matchShared: "match_shared"
        case .streamOpened: "stream_opened"
        case .streamOpenFailed: "stream_open_failed"
        case .errorShown: "tournaments_error_shown"
        case .errorRetryTapped: "tournaments_error_retry_tapped"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .tabOpened:
            return [:]
        case .segmentSwitched(let segment):
            return ["segment": segment.rawValue]
        case .gameSwitched(let game):
            return ["game": game.rawValue]
        case .pulledToRefresh(let screen):
            return ["screen": screen.rawValue]
        case .listScrolledToBottom(let page):
            return ["page": page]
        case .tournamentOpened(let id, let slug, let from):
            return [
                "tournament_id": id,
                "tournament_slug": slug,
                "from_screen": from.rawValue
            ]
        case .tournamentTabSwitched(let id, let tab):
            return [
                "tournament_id": id,
                "tab": tab.rawValue
            ]
        case .tournamentStageSwitched(let from, let to, let serieId):
            return [
                "from_stage_id": from,
                "to_stage_id": to,
                "serie_id": serieId
            ]
        case .tournamentShared(let id, let slug):
            return [
                "tournament_id": id,
                "tournament_slug": slug
            ]
        case .liveStripShown(let count, let game):
            return ["count": count, "game": game.rawValue]
        case .liveStripChipTapped(let matchId, let position):
            return ["match_id": matchId, "position": position]
        case .matchOpened(let id, let status, let from):
            return [
                "match_id": id,
                "status": status.rawValue,
                "from_screen": from.rawValue
            ]
        case .matchHasStreamsCount(let matchId, let count):
            return ["match_id": matchId, "count": count]
        case .matchShared(let id):
            return ["match_id": id]
        case .streamOpened(let matchId, let platform, let language, let isMain, let isOfficial):
            return [
                "match_id": matchId,
                "platform": platform.rawValue,
                "language": language,
                "is_main": isMain,
                "is_official": isOfficial
            ]
        case .streamOpenFailed(let matchId, let platform, let reason):
            return [
                "match_id": matchId,
                "platform": platform.rawValue,
                "reason": reason.rawValue
            ]
        case .errorShown(let screen, let kind):
            return ["screen": screen.rawValue, "kind": kind.rawValue]
        case .errorRetryTapped(let screen, let kind):
            return ["screen": screen.rawValue, "kind": kind.rawValue]
        }
    }
}

// MARK: - Reporter

protocol TournamentsAnalyticsReporting: Sendable {
    func report(_ event: TournamentsAnalyticsEvent)
}

struct TournamentsAnalytics: TournamentsAnalyticsReporting {
    static let shared = TournamentsAnalytics()

    func report(_ event: TournamentsAnalyticsEvent) {
        AppMetricaReporter.reportEvent(event.name, parameters: event.parameters)
    }
}
