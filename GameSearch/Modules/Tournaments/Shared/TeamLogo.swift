//
//  TeamLogo.swift
//  GameSearch
//
//  Renders a team logo from a remote URL. When the URL is missing or the
//  image fails to load, falls back to a colored circle with the team's
//  acronym (or first letters of the name). Used across all match views.
//

import SwiftUI
import CachedAsyncImage

struct TeamLogo: View {
    let team: Team?
    var size: CGFloat = 40

    var body: some View {
        Group {
            if let url = team?.imageUrl {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        fallback
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(size * 0.08)
                    case .failure:
                        fallback
                    @unknown default:
                        fallback
                    }
                }
            } else {
                fallback
            }
        }
        .frame(width: size, height: size)
        .background(
            Circle()
                .fill(EAColor.secondaryBackground)
        )
        .clipShape(Circle())
        .accessibilityLabel(Text(team?.name ?? "Команда"))
    }
}

private extension TeamLogo {
    var fallback: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            EAColor.purpleAccent.opacity(0.55),
                            EAColor.info2.opacity(0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(initials)
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundStyle(EAColor.textPrimary)
        }
    }

    var initials: String {
        if let acronym = team?.acronym, !acronym.isEmpty {
            return String(acronym.prefix(3)).uppercased()
        }
        guard let name = team?.name, !name.isEmpty else { return "?" }
        let words = name.split(separator: " ")
        let firstTwo = words.prefix(2).compactMap { $0.first }
        if firstTwo.isEmpty {
            return String(name.prefix(2)).uppercased()
        }
        return String(firstTwo).uppercased()
    }
}

#Preview {
    HStack(spacing: 16) {
        TeamLogo(team: nil, size: 64)
        TeamLogo(
            team: Team(
                id: 1,
                name: "Team Spirit",
                slug: "team-spirit",
                acronym: "TS",
                location: nil,
                imageUrl: nil,
                currentGame: .cs2,
                players: nil,
                modifiedAt: nil
            ),
            size: 64
        )
        TeamLogo(
            team: Team(
                id: 2,
                name: "Natus Vincere",
                slug: "navi",
                acronym: nil,
                location: nil,
                imageUrl: nil,
                currentGame: .cs2,
                players: nil,
                modifiedAt: nil
            ),
            size: 64
        )
    }
    .padding()
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
