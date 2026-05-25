//
//  LeagueMapper.swift
//  GameSearch
//

import Foundation

enum LeagueMapper {

    static func map(_ dto: PandaScoreLeagueDTO?) -> League? {
        guard let dto, let id = dto.id, let name = dto.name, let slug = dto.slug else {
            return nil
        }
        return League(
            id: id,
            name: name,
            slug: slug,
            imageUrl: dto.imageUrl.flatMap(URL.init(string:))
        )
    }
}
