//
//  ParticipantTeamCard.swift
//  GameSearch
//
//  One participating team card with its roster on the
//  `ParticipantsTab` of `TournamentDetailsView`.
//

import SwiftUI

struct ParticipantTeamCard: View {
    let participant: TournamentParticipant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if participant.players.isEmpty {
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

private extension ParticipantTeamCard {

    var header: some View {
        HStack(spacing: 10) {
            TeamLogo(team: participant.team, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(participant.team.name)
                    .font(EAFont.smallTitle)
                    .foregroundStyle(EAColor.textPrimary)
                    .lineLimit(1)
                if let location = participant.team.location, !location.isEmpty {
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
        VStack(alignment: .leading, spacing: 8) {
            Text(TournamentsStrings.participantsRosterLabel.uppercased())
                .font(EAFont.infoSmall)
                .foregroundStyle(EAColor.textSecondary)
            VStack(spacing: 6) {
                ForEach(participant.players) { player in
                    playerRow(player)
                }
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
    func player(id: Int, nick: String, country: String?, role: String?) -> Player {
        Player(
            id: id, nickname: nick, firstName: nil, lastName: nil,
            nationality: country, age: nil, birthday: nil, role: role, active: true,
            imageUrl: nil, currentTeam: nil, currentGame: .cs2
        )
    }
    let team = Team(
        id: 1, name: "FaZe Clan", slug: "faze", acronym: "FaZe",
        location: "Europe", imageUrl: nil, currentGame: .cs2,
        players: nil, modifiedAt: nil
    )
    let participant = TournamentParticipant(
        team: team,
        players: [
            player(id: 1, nick: "karrigan", country: "DK", role: "IGL"),
            player(id: 2, nick: "rain", country: "NO", role: "Rifler"),
            player(id: 3, nick: "broky", country: "FI", role: "AWPer"),
            player(id: 4, nick: "Twistzz", country: "CA", role: "Rifler"),
            player(id: 5, nick: "frozen", country: "SK", role: "Rifler")
        ]
    )
    return ScrollView {
        VStack(spacing: 12) {
            ParticipantTeamCard(participant: participant)
            ParticipantTeamCard(participant: TournamentParticipant(
                team: Team(id: 2, name: "NaVi", slug: "navi", acronym: "NaVi",
                           location: nil, imageUrl: nil, currentGame: .cs2,
                           players: nil, modifiedAt: nil),
                players: []
            ))
        }
        .padding()
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
