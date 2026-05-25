//
//  TournamentMapper.swift
//  GameSearch
//

import Foundation

enum TournamentMapper {

    static func map(_ dto: PandaScoreTournamentDTO?) -> Tournament? {
        guard
            let dto,
            let id = dto.id,
            let slug = dto.slug,
            let name = dto.name,
            let league = LeagueMapper.map(dto.league),
            let serie = SerieMapper.map(dto.serie),
            let game = Game(pandaScoreSlug: dto.videogame?.slug)
                ?? Game(pandaScoreId: dto.videogame?.id)
        else { return nil }

        let participants = (dto.expectedRoster ?? []).compactMap(mapParticipant)

        return Tournament(
            id: id,
            slug: slug,
            name: name,
            tier: dto.tier.flatMap { Tier(rawValue: $0.lowercased()) },
            game: game,
            league: league,
            serie: serie,
            beginAt: dto.beginAt,
            endAt: dto.endAt,
            prizepool: PrizepoolFormatter.parse(dto.prizepool),
            country: dto.country,
            region: dto.region,
            liveSupported: dto.liveSupported ?? false,
            modifiedAt: dto.modifiedAt,
            matches: dto.matches.map(MatchMapper.mapAll(_:)),
            participants: participants.isEmpty ? nil : participants
        )
    }

    static func mapAll(_ dtos: [PandaScoreTournamentDTO]?) -> [Tournament] {
        (dtos ?? []).compactMap(map)
    }
}

private extension TournamentMapper {

    static func mapParticipant(_ dto: PandaScoreRosterDTO) -> TournamentParticipant? {
        guard let team = TeamMapper.map(dto.team) else { return nil }
        let players = (dto.players ?? []).compactMap(PlayerMapper.map)
        return TournamentParticipant(team: team, players: players)
    }
}
