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
            wins: dto.wins ?? 0,
            losses: dto.losses ?? 0,
            ties: dto.ties,
            points: dto.points
        )
    }

    static func mapAll(_ dtos: [PandaScoreStandingDTO]?) -> [Standing] {
        (dtos ?? []).compactMap(map)
    }
}
