//
//  PandaScoreTeamDTO.swift
//  GameSearch
//

import Foundation

struct PandaScoreTeamDTO: Decodable, Sendable {
    let id: Int?
    let name: String?
    let slug: String?
    let acronym: String?
    let location: String?
    let imageUrl: String?
    let currentVideogame: PandaScoreVideogameDTO?
    let players: [PandaScorePlayerDTO]?
    let modifiedAt: Date?
}
