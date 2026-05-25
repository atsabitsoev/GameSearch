//
//  TournamentHeaderView.swift
//  GameSearch
//
//  Top hero card for `TournamentDetailsView`. Layout follows
//  `docs/tournaments/10-screens.md`:
//      [Logo]
//      League
//      Series · Stage
//      21 мар — 31 мар
//      🇩🇰 Country  [Tier]
//      💰 $1.25M
//

import SwiftUI
import CachedAsyncImage

struct TournamentHeaderView: View {
    let tournament: Tournament

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            leagueLogo
            VStack(spacing: 6) {
                Text(tournament.league.name)
                    .font(EAFont.smallTitle)
                    .foregroundStyle(EAColor.textSecondary)
                    .lineLimit(1)
                Text(tournament.displayListTitle)
                    .font(EAFont.header)
                    .foregroundStyle(EAColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                if !tournament.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(tournament.name)
                        .font(EAFont.info)
                        .foregroundStyle(EAColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
            }
            DateRangeLabel(from: tournament.beginAt, to: tournament.endAt)
            badgesRow
            if tournament.prizepool != nil {
                PrizepoolLabel(prizepool: tournament.prizepool)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }
}

private extension TournamentHeaderView {

    var leagueLogo: some View {
        let placeholder = RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(EAColor.background)
            .overlay(
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(EAColor.textSecondary)
            )

        return Group {
            if let url = tournament.league.imageUrl {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                    case .failure: placeholder
                    @unknown default: placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 72, height: 72)
        .background(EAColor.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    var badgesRow: some View {
        HStack(spacing: 10) {
            if tournament.isLive {
                LiveBadge()
            }
            if let country = tournament.country {
                HStack(spacing: 4) {
                    CountryFlag(code: country)
                    Text(country.uppercased())
                        .font(EAFont.description)
                        .foregroundStyle(EAColor.textSecondary)
                }
            }
            if let tier = tournament.tier {
                TierBadge(tier: tier)
            }
        }
    }
}

#Preview {
    let league = League(
        id: 1,
        name: "PGL",
        slug: "pgl",
        imageUrl: nil
    )
    let serie = Serie(
        id: 1,
        name: "Major Copenhagen",
        fullName: "Major Copenhagen 2026",
        year: 2026,
        season: nil
    )
    let tournament = Tournament(
        id: 1,
        slug: "pgl-major-copenhagen-2026-playoffs",
        name: "Playoffs",
        tier: .s,
        game: .cs2,
        league: league,
        serie: serie,
        beginAt: Date(),
        endAt: Date().addingTimeInterval(86400 * 7),
        prizepool: Prizepool(amount: 1_250_000, currency: "United States Dollar"),
        country: "DK",
        region: "Europe",
        liveSupported: true,
        modifiedAt: nil,
        matches: nil,
        participants: nil
    )
    return ScrollView {
        TournamentHeaderView(tournament: tournament)
            .padding()
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
