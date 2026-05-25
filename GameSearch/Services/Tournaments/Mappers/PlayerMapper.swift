//
//  PlayerMapper.swift
//  GameSearch
//

import Foundation

enum PlayerMapper {

    private static let birthdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func map(_ dto: PandaScorePlayerDTO?) -> Player? {
        guard let dto, let id = dto.id, let nickname = dto.name else { return nil }
        return Player(
            id: id,
            nickname: nickname,
            firstName: dto.firstName,
            lastName: dto.lastName,
            nationality: dto.nationality,
            age: dto.age,
            birthday: dto.birthday.flatMap(birthdayFormatter.date(from:)),
            role: dto.role,
            active: dto.active ?? true,
            imageUrl: dto.imageUrl.flatMap(URL.init(string:)),
            currentTeam: TeamMapper.map(dto.currentTeam),
            currentGame: Game(pandaScoreSlug: dto.currentVideogame?.slug)
                ?? Game(pandaScoreId: dto.currentVideogame?.id)
        )
    }

    static func mapAll(_ dtos: [PandaScorePlayerDTO]?) -> [Player] {
        (dtos ?? []).compactMap(map)
    }
}
