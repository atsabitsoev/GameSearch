//
//  PandaScorePlayerDTO.swift
//  GameSearch
//

import Foundation

struct PandaScorePlayerDTO: Decodable, Sendable {
    let id: Int?
    let name: String?
    let firstName: String?
    let lastName: String?
    let nationality: String?
    let age: Int?
    let birthday: String?
    let role: String?
    let active: Bool?
    let imageUrl: String?
    let currentTeam: PandaScoreTeamDTO?
    let currentVideogame: PandaScoreVideogameDTO?
    let modifiedAt: Date?
}
