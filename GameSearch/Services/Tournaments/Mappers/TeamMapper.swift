//
//  TeamMapper.swift
//  GameSearch
//

import Foundation

enum TeamMapper {

    static func map(_ dto: PandaScoreTeamDTO?) -> Team? {
        guard let dto, let id = dto.id, let name = dto.name else { return nil }
        return Team(
            id: id,
            name: name,
            slug: dto.slug ?? "",
            acronym: dto.acronym,
            location: dto.location,
            imageUrl: dto.imageUrl.flatMap(URL.init(string:)),
            currentGame: Game(pandaScoreSlug: dto.currentVideogame?.slug)
                ?? Game(pandaScoreId: dto.currentVideogame?.id),
            players: dto.players.map { $0.compactMap(PlayerMapper.map) },
            modifiedAt: dto.modifiedAt
        )
    }
}
