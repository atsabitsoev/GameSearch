//
//  Deeplink.swift
//  GameSearch
//
//  Created by Ацамаз on 27.12.2025.
//

import Foundation

enum Deeplink: Equatable {
    case articles(slug: String?)
    case tournamentsTab(game: Game?)
    case tournamentDetails(idOrSlug: String)
    case matchDetails(id: MatchId)

    init?(from url: URL) {
        let (route, params) = Deeplink.routeAndParams(from: url)
        guard let route, !route.isEmpty else { return nil }

        switch route {
        case "news":
            if let slug = params.first {
                self = .articles(slug: slug)
            } else {
                self = .articles(slug: nil)
            }
        case "tournaments":
            if let gameToken = params.first {
                self = .tournamentsTab(game: Game(rawValue: gameToken))
            } else {
                self = .tournamentsTab(game: nil)
            }
        case "tournament":
            guard let idOrSlug = params.first else { return nil }
            self = .tournamentDetails(idOrSlug: idOrSlug)
        case "match":
            guard let token = params.first, let id = Int(token) else { return nil }
            self = .matchDetails(id: id)
        default:
            return nil
        }
    }

    /// Returns the first path segment (the "route") and the remaining
    /// path segments. Works both for custom-scheme URLs (`gamesearch://route/p1`)
    /// where the route lives in `host`, and for universal-link URLs
    /// (`https://gamesearch.app/route/p1`) where the route is the first
    /// path component.
    private static func routeAndParams(from url: URL) -> (route: String?, params: [String]) {
        let pathSegments = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
        if let host = url.host, !host.isEmpty, url.scheme != "http", url.scheme != "https" {
            return (host, pathSegments)
        }
        guard let first = pathSegments.first else { return (nil, []) }
        return (first, Array(pathSegments.dropFirst()))
    }
}
