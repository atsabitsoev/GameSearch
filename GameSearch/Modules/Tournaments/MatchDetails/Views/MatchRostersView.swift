//
//  MatchRostersView.swift
//  GameSearch
//
//  "Составы" section of `MatchDetailsView`. Shows up to two rosters
//  side-by-side (one per opponent). Players come from
//  `opponent.team.players` which PandaScore populates on
//  `/matches/{id}` for teams it has a confirmed roster for.
//
//  When neither team has a roster — the entire section is hidden
//  (avoids rendering an empty box). When only one side has a roster,
//  we still render both team headers so the user understands which
//  side is missing data.
//

import SwiftUI

struct MatchRostersView: View {
    let match: Match

    var body: some View {
        if let rosters = rosters {
            VStack(alignment: .leading, spacing: 8) {
                Text(TournamentsStrings.matchSectionRosters)
                    .font(EAFont.header)
                    .foregroundStyle(EAColor.textPrimary)
                    .padding(.horizontal, 16)
                VStack(spacing: 12) {
                    ForEach(rosters, id: \.team.id) { roster in
                        TeamRosterCard(team: roster.team, players: roster.players)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private extension MatchRostersView {

    struct RosterEntry {
        let team: Team
        let players: [Player]
    }

    /// Returns nil when no opponent has any players (entire section
    /// suppressed). Otherwise returns one entry per opponent.
    var rosters: [RosterEntry]? {
        let entries = match.opponents.map { opp in
            RosterEntry(team: opp.team, players: opp.team.players ?? [])
        }
        guard entries.contains(where: { !$0.players.isEmpty }) else { return nil }
        return entries
    }
}

// MARK: - Roster card

private struct TeamRosterCard: View {
    let team: Team
    let players: [Player]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if players.isEmpty {
                Text(TournamentsStrings.participantsNoRoster)
                    .font(EAFont.info)
                    .foregroundStyle(EAColor.textSecondary)
            } else {
                rosterList
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }
}

private extension TeamRosterCard {

    var header: some View {
        HStack(spacing: 10) {
            TeamLogo(team: team, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(EAFont.smallTitle)
                    .foregroundStyle(EAColor.textPrimary)
                    .lineLimit(1)
                if let location = team.location, !location.isEmpty {
                    Text(location)
                        .font(EAFont.description)
                        .foregroundStyle(EAColor.textSecondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
    }

    var rosterList: some View {
        VStack(spacing: 6) {
            ForEach(players) { player in
                playerRow(player)
            }
        }
    }

    func playerRow(_ player: Player) -> some View {
        HStack(spacing: 8) {
            Text("•")
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
            Text(player.nickname)
                .font(EAFont.smallTitle)
                .foregroundStyle(EAColor.textPrimary)
                .lineLimit(1)
            if let nationality = player.nationality {
                CountryFlag(code: nationality)
            }
            if let role = player.role, !role.isEmpty {
                Text(role)
                    .font(EAFont.description)
                    .foregroundStyle(EAColor.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    func player(_ id: Int, _ nick: String, country: String?, role: String?) -> Player {
        Player(id: id, nickname: nick, firstName: nil, lastName: nil,
               nationality: country, age: nil, birthday: nil, role: role, active: true,
               imageUrl: nil, currentTeam: nil, currentGame: .cs2)
    }
    let faze = Team(
        id: 1, name: "FaZe Clan", slug: "faze", acronym: "FAZE",
        location: "Europe", imageUrl: nil, currentGame: .cs2,
        players: [
            player(1, "karrigan", country: "DK", role: "IGL"),
            player(2, "rain", country: "NO", role: "Rifler"),
            player(3, "broky", country: "FI", role: "AWPer"),
            player(4, "Twistzz", country: "CA", role: "Rifler"),
            player(5, "frozen", country: "SK", role: "Rifler")
        ],
        modifiedAt: nil
    )
    let navi = Team(
        id: 2, name: "Natus Vincere", slug: "navi", acronym: "NaVi",
        location: "Ukraine", imageUrl: nil, currentGame: .cs2,
        players: nil,
        modifiedAt: nil
    )
    let match = Match(
        id: 1, name: "FaZe vs NaVi", status: .running, matchType: .bestOf,
        numberOfGames: 5, scheduledAt: nil, beginAt: Date(), endAt: nil,
        draw: false, forfeit: false, tournamentId: 1, leagueId: 1, game: .cs2,
        opponents: [Match.Opponent(team: faze), Match.Opponent(team: navi)],
        results: [], games: [], streams: [], winnerId: nil
    )
    return ScrollView {
        MatchRostersView(match: match)
            .padding(.vertical, 16)
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
