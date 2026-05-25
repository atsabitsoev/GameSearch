//
//  TournamentsSkeletonList.swift
//  GameSearch
//
//  Skeleton list shown while we have no cached data yet for a given
//  game+segment. Animation cadence follows ArticlesSkeletonCard.
//

import SwiftUI

struct TournamentsSkeletonList: View {
    var cardCount: Int = 5
    var showsLiveStrip: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if showsLiveStrip {
                liveStripSkeleton
            }
            VStack(spacing: 12) {
                ForEach(0..<cardCount, id: \.self) { _ in
                    TournamentCardSkeleton()
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }
}

private extension TournamentsSkeletonList {
    var liveStripSkeleton: some View {
        VStack(alignment: .leading, spacing: 10) {
            SkeletonRectangle(width: 140, height: 16)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(EAColor.secondaryBackground.opacity(0.6))
                            .frame(width: 160, height: 130)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct TournamentCardSkeleton: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.6))
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 10) {
                SkeletonRectangle(width: 180, height: 14)
                SkeletonRectangle(width: 120, height: 12)
                SkeletonRectangle(width: 220, height: 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground)
        )
    }
}

struct SkeletonRectangle: View {
    let width: CGFloat
    let height: CGFloat

    @State private var animate = false

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(EAColor.secondaryBackground.opacity(0.6))
            .frame(width: width, height: height)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.08),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: animate ? width : -width)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
    }
}

#Preview {
    ScrollView {
        TournamentsSkeletonList()
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
