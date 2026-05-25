//
//  BracketsTab.swift
//  GameSearch
//
//  Placeholder tab — real bracket visualization is scheduled for
//  Phase 4 (Polish). See `docs/tournaments/15-roadmap.md`.
//

import SwiftUI

struct BracketsTab: View {
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(EAColor.secondaryBackground)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "square.grid.3x2")
                        .font(.system(size: 26))
                        .foregroundStyle(EAColor.textSecondary)
                )
            Text(TournamentsStrings.tournamentBracketsComingSoonTitle)
                .font(EAFont.smallTitle)
                .foregroundStyle(EAColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(TournamentsStrings.tournamentBracketsComingSoonSubtitle)
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

#Preview {
    ScrollView {
        BracketsTab()
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
