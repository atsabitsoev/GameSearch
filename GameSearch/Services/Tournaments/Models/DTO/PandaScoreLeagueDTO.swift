//
//  PandaScoreLeagueDTO.swift
//  GameSearch
//

import Foundation

struct PandaScoreLeagueDTO: Decodable, Sendable {
    let id: Int?
    let name: String?
    let slug: String?
    let imageUrl: String?
}
