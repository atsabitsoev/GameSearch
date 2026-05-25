//
//  LiveBadge.swift
//  GameSearch
//
//  Pulsing "● LIVE" badge used across the Tournaments module.
//  Pulse animation cadence follows `docs/tournaments/11-design-system.md`.
//

import SwiftUI

struct LiveBadge: View {
    var compact: Bool = false

    @State private var pulse: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
                .opacity(pulse ? 0.35 : 1.0)
                .scaleEffect(pulse ? 0.85 : 1.0)
            if !compact {
                Text(TournamentsStrings.matchStatusLive)
                    .font(EAFont.infoSmall)
                    .fontWeight(.bold)
                    .foregroundStyle(EAColor.textPrimary)
            }
        }
        .padding(.horizontal, compact ? 4 : 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.red.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.red.opacity(0.55), lineWidth: 1)
        )
        .accessibilityLabel(Text("В прямом эфире"))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        LiveBadge()
        LiveBadge(compact: true)
    }
    .padding()
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
