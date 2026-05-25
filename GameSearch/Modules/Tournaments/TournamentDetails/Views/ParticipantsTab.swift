//
//  ParticipantsTab.swift
//  GameSearch
//
//  "Команды" tab of `TournamentDetailsView`. Data comes pre-loaded
//  inside the `Tournament` payload (`expected_roster`), so no extra
//  network request is needed here.
//

import SwiftUI

struct ParticipantsTab: View {
    let tournament: Tournament

    var body: some View {
        if let participants = tournament.participants, !participants.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(TournamentsStrings.participantsSectionTitle)
                    .font(EAFont.header)
                    .foregroundStyle(EAColor.textPrimary)
                    .padding(.horizontal, 16)
                LazyVStack(spacing: 12) {
                    ForEach(participants) { participant in
                        ParticipantTeamCard(participant: participant)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        } else {
            ParticipantsEmptyView()
        }
    }
}

private struct ParticipantsEmptyView: View {
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(EAColor.secondaryBackground)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(EAColor.textSecondary)
                )
            Text(TournamentsStrings.participantsEmptyTitle)
                .font(EAFont.smallTitle)
                .foregroundStyle(EAColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(TournamentsStrings.participantsEmptySubtitle)
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
