//
//  PandaScoreStandingDTO.swift
//  GameSearch
//

import Foundation

struct PandaScoreStandingDTO: Decodable, Sendable {
    let team: PandaScoreTeamDTO?
    let rank: Int?
    let wins: Int?
    let losses: Int?
    let ties: Int?
    let points: Int?
}
