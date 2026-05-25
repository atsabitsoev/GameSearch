//
//  PandaScoreTournamentDTO.swift
//  GameSearch
//

import Foundation

struct PandaScoreTournamentDTO: Decodable, Sendable {
    let id: Int?
    let slug: String?
    let name: String?
    let tier: String?
    let beginAt: Date?
    let endAt: Date?
    let prizepool: String?
    let country: String?
    let region: String?
    let liveSupported: Bool?
    let modifiedAt: Date?
    let league: PandaScoreLeagueDTO?
    let serie: PandaScoreSerieDTO?
    let videogame: PandaScoreVideogameDTO?
    let matches: [PandaScoreMatchDTO]?
    let expectedRoster: [PandaScoreRosterDTO]?
}

struct PandaScoreRosterDTO: Decodable, Sendable {
    let team: PandaScoreTeamDTO?
    let players: [PandaScorePlayerDTO]?
}
