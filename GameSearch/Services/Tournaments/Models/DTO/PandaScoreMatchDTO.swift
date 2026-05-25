//
//  PandaScoreMatchDTO.swift
//  GameSearch
//

import Foundation

struct PandaScoreMatchDTO: Decodable, Sendable {
    let id: Int?
    let name: String?
    let status: String?
    let matchType: String?
    let numberOfGames: Int?
    let beginAt: Date?
    let scheduledAt: Date?
    let endAt: Date?
    let modifiedAt: Date?
    let draw: Bool?
    let forfeit: Bool?
    let tournamentId: Int?
    let leagueId: Int?
    let serieId: Int?
    let winnerId: Int?
    let winnerType: String?
    let videogame: PandaScoreVideogameDTO?
    let opponents: [PandaScoreMatchOpponentDTO]?
    let results: [PandaScoreMatchResultDTO]?
    let games: [PandaScoreMatchGameDTO]?
    let streamsList: [PandaScoreStreamDTO]?
}

struct PandaScoreMatchOpponentDTO: Decodable, Sendable {
    let type: String?
    let opponent: PandaScoreTeamDTO?
}

struct PandaScoreMatchResultDTO: Decodable, Sendable {
    let teamId: Int?
    let score: Int?
}

struct PandaScoreMatchGameDTO: Decodable, Sendable {
    let id: Int?
    let position: Int?
    let status: String?
    let winner: PandaScoreWinnerRefDTO?
    let beginAt: Date?
    let endAt: Date?
    let length: TimeInterval?
    let videoUrl: String?
    let map: PandaScoreMapDTO?
}

struct PandaScoreMapDTO: Decodable, Sendable {
    let name: String?
}
