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
    /// Total matches played = wins + losses + ties. PandaScore returns
    /// this for group/Swiss-format standings.
    let total: Int?
    /// Map-level wins inside this standings entry (CS2 group stage).
    let gameWins: Int?
    let gameLosses: Int?
    let gameTies: Int?
}
