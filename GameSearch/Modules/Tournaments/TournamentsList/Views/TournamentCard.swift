//
//  TournamentCard.swift
//  GameSearch
//
//  Card cell for one *series* of a tournament inside the main list. We
//  intentionally show one card per series (PandaScore returns each stage as
//  a separate `Tournament`); stages are concatenated as the subtitle and
//  dates / prize pool are aggregated across them.
//
//  Composition follows `docs/tournaments/10-screens.md`:
//      [LeagueLogo]  Serie / League title          [TierBadge]
//                    Stage 1 · Stage 2 · Playoffs
//                    21 мар — 31 мар  ·  $1.25M
//

import SwiftUI
import CachedAsyncImage

struct TournamentCard: View {
    let group: TournamentSeriesGroup

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            leagueLogo
            VStack(alignment: .leading, spacing: 6) {
                titleRow
                Text(group.stageNamesJoined)
                    .font(EAFont.info)
                    .foregroundStyle(EAColor.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                metaRow
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
        .overlay(alignment: .topLeading) {
            if group.isLive {
                LiveBadge(compact: true)
                    .padding(8)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private extension TournamentCard {

    var leagueLogo: some View {
        let placeholder = RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(EAColor.secondaryBackground.opacity(0.6))
            .overlay(
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(EAColor.textSecondary)
            )

        return Group {
            if let url = group.league.imageUrl {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(4)
                    case .failure: placeholder
                    @unknown default: placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 44, height: 44)
        .background(EAColor.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    var titleRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(group.displayTitle)
                .font(EAFont.smallTitle)
                .foregroundStyle(EAColor.textPrimary)
                .lineLimit(1)
            if let tier = group.tier {
                TierBadge(tier: tier)
            }
            Spacer(minLength: 0)
        }
    }

    var metaRow: some View {
        HStack(spacing: 8) {
            DateRangeLabel(from: group.beginAt, to: group.endAt)
            if group.prizepool != nil {
                Text("·")
                    .font(EAFont.description)
                    .foregroundStyle(EAColor.textSecondary)
                PrizepoolLabel(prizepool: group.prizepool)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    let league = League(id: 1, name: "PGL", slug: "pgl", imageUrl: nil)
    let serie = Serie(
        id: 1,
        name: "Major Copenhagen",
        fullName: "Major Copenhagen 2026",
        year: 2026,
        season: nil
    )
    func stage(id: Int, name: String, prize: Decimal?) -> Tournament {
        Tournament(
            id: id,
            slug: "stage-\(id)",
            name: name,
            tier: .s,
            game: .cs2,
            league: league,
            serie: serie,
            beginAt: Date(),
            endAt: Date().addingTimeInterval(86400 * 5),
            prizepool: prize.map { Prizepool(amount: $0, currency: "USD") },
            country: "DK",
            region: "Europe",
            liveSupported: true,
            modifiedAt: nil,
            matches: nil,
            participants: nil
        )
    }
    let group = TournamentSeriesGroup(
        serie: serie,
        league: league,
        game: .cs2,
        stages: [
            stage(id: 1, name: "Group A", prize: nil),
            stage(id: 2, name: "Group B", prize: nil),
            stage(id: 3, name: "Playoffs", prize: 1_250_000)
        ]
    )

    return VStack(spacing: 12) {
        TournamentCard(group: group)
    }
    .padding()
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
