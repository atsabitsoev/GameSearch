//
//  MatchMapper.swift
//  GameSearch
//

import Foundation

enum MatchMapper {

    static func map(_ dto: PandaScoreMatchDTO?) -> Match? {
        guard
            let dto,
            let id = dto.id,
            let tournamentId = dto.tournamentId,
            let leagueId = dto.leagueId,
            let game = Game(pandaScoreSlug: dto.videogame?.slug)
                ?? Game(pandaScoreId: dto.videogame?.id)
        else { return nil }

        let status = MatchStatus(rawValue: dto.status ?? "") ?? .notStarted
        let matchType = MatchType(rawValue: dto.matchType ?? "") ?? .bestOf
        let opponents = (dto.opponents ?? []).compactMap(mapOpponent)
        let results = (dto.results ?? []).compactMap(mapResult)
        let games = (dto.games ?? []).compactMap(mapGame)
        let streams = StreamMapper.mapAll(dto.streamsList)

        return Match(
            id: id,
            name: dto.name ?? "",
            status: status,
            matchType: matchType,
            numberOfGames: dto.numberOfGames ?? 1,
            scheduledAt: dto.scheduledAt,
            beginAt: dto.beginAt,
            endAt: dto.endAt,
            draw: dto.draw ?? false,
            forfeit: dto.forfeit ?? false,
            tournamentId: tournamentId,
            leagueId: leagueId,
            game: game,
            opponents: opponents,
            results: results,
            games: games,
            streams: streams,
            winnerId: dto.winnerId
        )
    }

    static func mapAll(_ dtos: [PandaScoreMatchDTO]?) -> [Match] {
        (dtos ?? []).compactMap(map)
    }
}

private extension MatchMapper {

    static func mapOpponent(_ dto: PandaScoreMatchOpponentDTO) -> Match.Opponent? {
        guard let team = TeamMapper.map(dto.opponent) else { return nil }
        return Match.Opponent(team: team)
    }

    static func mapResult(_ dto: PandaScoreMatchResultDTO) -> Match.MatchResult? {
        guard let teamId = dto.teamId, let score = dto.score else { return nil }
        return Match.MatchResult(teamId: teamId, score: score)
    }

    static func mapGame(_ dto: PandaScoreMatchGameDTO) -> Match.PlayedGame? {
        guard let id = dto.id, let position = dto.position else { return nil }
        let status = MatchStatus(rawValue: dto.status ?? "") ?? .notStarted
        return Match.PlayedGame(
            id: id,
            position: position,
            status: status,
            mapName: dto.map?.name,
            winnerId: dto.winner?.id,
            beginAt: dto.beginAt,
            endAt: dto.endAt,
            length: dto.length,
            videoUrl: dto.videoUrl.flatMap(URL.init(string:))
        )
    }
}
