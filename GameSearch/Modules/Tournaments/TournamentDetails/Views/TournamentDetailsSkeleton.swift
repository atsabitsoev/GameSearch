//
//  TournamentDetailsSkeleton.swift
//  GameSearch
//
//  Skeleton shown while we have no cached payload for the requested
//  tournament. Composition mirrors the loaded layout: header card
//  followed by tab picker stub and a few match-row stubs.
//

import SwiftUI

struct TournamentDetailsSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSkeleton
                .padding(.horizontal, 16)
            tabPickerSkeleton
                .padding(.horizontal, 16)
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    matchRowSkeleton
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
}

private extension TournamentDetailsSkeleton {

    var headerSkeleton: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.6))
                .frame(width: 72, height: 72)
            SkeletonRectangle(width: 120, height: 14)
            SkeletonRectangle(width: 220, height: 18)
            SkeletonRectangle(width: 160, height: 14)
            HStack(spacing: 10) {
                SkeletonRectangle(width: 50, height: 18)
                SkeletonRectangle(width: 30, height: 18)
            }
            SkeletonRectangle(width: 120, height: 16)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }

    var tabPickerSkeleton: some View {
        HStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { _ in
                SkeletonRectangle(width: 80, height: 32)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.55))
        )
    }

    var matchRowSkeleton: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(EAColor.secondaryBackground.opacity(0.6))
                    .frame(width: 28, height: 28)
                SkeletonRectangle(width: 100, height: 14)
                Spacer()
                SkeletonRectangle(width: 24, height: 14)
            }
            SkeletonRectangle(width: 40, height: 10)
            HStack(spacing: 10) {
                Circle()
                    .fill(EAColor.secondaryBackground.opacity(0.6))
                    .frame(width: 28, height: 28)
                SkeletonRectangle(width: 120, height: 14)
                Spacer()
                SkeletonRectangle(width: 24, height: 14)
            }
            SkeletonRectangle(width: 140, height: 12)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }
}

#Preview {
    ScrollView {
        TournamentDetailsSkeleton()
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
