//
//  League.swift
//  GameSearch
//

import Foundation

struct League: Identifiable, Hashable, Sendable, Codable {
    let id: LeagueId
    let name: String
    let slug: String
    let imageUrl: URL?
}
