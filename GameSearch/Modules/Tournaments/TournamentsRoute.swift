//
//  TournamentsRoute.swift
//  GameSearch
//
//  Navigation routes for the Tournaments tab.
//

import Foundation

enum TournamentsRoute: Hashable {
    case tournamentDetails(idOrSlug: String)
    case matchDetails(id: MatchId)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .tournamentDetails(let idOrSlug):
            hasher.combine("t-\(idOrSlug)")
        case .matchDetails(let id):
            hasher.combine("m-\(id)")
        }
    }

    static func == (lhs: TournamentsRoute, rhs: TournamentsRoute) -> Bool {
        switch (lhs, rhs) {
        case let (.tournamentDetails(a), .tournamentDetails(b)):
            return a == b
        case let (.matchDetails(a), .matchDetails(b)):
            return a == b
        default:
            return false
        }
    }
}
