//
//  StandingMapper.swift
//  GameSearch
//

import Foundation

enum StandingMapper {

    static func map(_ dto: PandaScoreStandingDTO?) -> Standing? {
        guard let dto, let team = TeamMapper.map(dto.team), let rank = dto.rank else {
            return nil
        }
        return Standing(
            team: team,
            rank: rank,
            wins: dto.wins,
            losses: dto.losses,
            ties: dto.ties,
            points: dto.points,
            total: dto.total,
            gameWins: dto.gameWins,
            gameLosses: dto.gameLosses,
            gameTies: dto.gameTies
        )
    }

    static func mapAll(_ dtos: [PandaScoreStandingDTO]?) -> [Standing] {
        (dtos ?? []).compactMap(map)
    }
}
