//
//  Standing.swift
//  GameSearch
//

import Foundation

struct Standing: Hashable, Sendable, Codable, Identifiable {
    var id: TeamId { team.id }
    let team: Team
    let rank: Int
    /// Optional — PandaScore returns these for **group/Swiss** standings
    /// (the natural place for a leaderboard). Playoff brackets only return
    /// `rank` + `team` + `last_match` since the bracket itself encodes the
    /// progression. `StandingsColumnLayout` hides columns that are nil for
    /// every row so we never render "0/0/—" placeholders.
    let wins: Int?
    let losses: Int?
    let ties: Int?
    let points: Int?
    /// Total matches played. For CS2 Swiss groups this is `wins + losses`
    /// (ties always 0). Used to render the "M" (матчи) column.
    let total: Int?
    /// Map-level scores inside a Swiss/group stage — e.g. team won 7 maps
    /// and lost 2 across the stage. Used to render the "Карты" column as
    /// "7-2".
    let gameWins: Int?
    let gameLosses: Int?
    let gameTies: Int?
}
