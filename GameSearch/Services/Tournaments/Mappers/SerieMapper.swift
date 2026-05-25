//
//  SerieMapper.swift
//  GameSearch
//

import Foundation

enum SerieMapper {

    static func map(_ dto: PandaScoreSerieDTO?) -> Serie? {
        guard let dto, let id = dto.id else { return nil }
        return Serie(
            id: id,
            name: dto.name ?? "",
            fullName: dto.fullName,
            year: dto.year,
            season: dto.season
        )
    }
}
