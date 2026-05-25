//
//  MatchDetailsSkeleton.swift
//  GameSearch
//
//  Skeleton for the match details screen — shown while the primary
//  `/matches/{id}` fetch has no cache to serve. Mirrors the loaded
//  composition: header card, games list, streams list. Roster skeleton
//  is intentionally omitted (roster section is hidden entirely when
//  rosters aren't available — see `MatchRostersView`).
//

import SwiftUI

struct MatchDetailsSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            headerSkeleton
                .padding(.horizontal, 16)
            sectionSkeleton(title: "Карты", rowCount: 3)
            sectionSkeleton(title: "Где смотреть", rowCount: 2)
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
}

private extension MatchDetailsSkeleton {

    var headerSkeleton: some View {
        VStack(spacing: 14) {
            SkeletonRectangle(width: 160, height: 12)
            HStack(alignment: .center, spacing: 12) {
                teamColumnSkeleton
                centerColumnSkeleton
                teamColumnSkeleton
            }
            SkeletonRectangle(width: 140, height: 12)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }

    var teamColumnSkeleton: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(EAColor.secondaryBackground.opacity(0.6))
                .frame(width: 72, height: 72)
            SkeletonRectangle(width: 80, height: 14)
            SkeletonRectangle(width: 28, height: 22)
        }
        .frame(maxWidth: .infinity)
    }

    var centerColumnSkeleton: some View {
        VStack(spacing: 10) {
            SkeletonRectangle(width: 36, height: 14)
            SkeletonRectangle(width: 70, height: 18)
        }
        .frame(minWidth: 90)
    }

    func sectionSkeleton(title: String, rowCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SkeletonRectangle(width: 130, height: 18)
                .padding(.horizontal, 16)
            VStack(spacing: 6) {
                ForEach(0..<rowCount, id: \.self) { _ in
                    rowSkeleton
                }
            }
            .padding(.horizontal, 16)
        }
    }

    var rowSkeleton: some View {
        HStack(spacing: 12) {
            SkeletonRectangle(width: 24, height: 14)
            SkeletonRectangle(width: 120, height: 14)
            Spacer()
            SkeletonRectangle(width: 60, height: 14)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.55))
        )
    }
}

#Preview {
    ScrollView {
        MatchDetailsSkeleton()
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
