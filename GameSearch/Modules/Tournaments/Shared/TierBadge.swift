//
//  TierBadge.swift
//  GameSearch
//
//  Colored pill that shows a tournament tier (S / A / B / C / D).
//  Color palette follows `docs/tournaments/11-design-system.md`.
//

import SwiftUI

struct TierBadge: View {
    let tier: Tier

    var body: some View {
        Text(tier.displayName)
            .font(EAFont.infoSmall)
            .fontWeight(.bold)
            .foregroundStyle(textColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .accessibilityLabel(Text("Tier \(tier.displayName)"))
    }
}

private extension TierBadge {
    var textColor: Color {
        switch tier {
        case .s: EAColor.purpleAccent
        case .a: EAColor.info2
        case .b, .c, .d: EAColor.textSecondary
        }
    }

    var backgroundColor: Color {
        switch tier {
        case .s: EAColor.purpleAccent.opacity(0.18)
        case .a: EAColor.info2.opacity(0.18)
        case .b, .c, .d: EAColor.secondaryBackground
        }
    }

    var borderColor: Color {
        textColor.opacity(0.55)
    }
}

#Preview {
    HStack(spacing: 8) {
        TierBadge(tier: .s)
        TierBadge(tier: .a)
        TierBadge(tier: .b)
        TierBadge(tier: .c)
        TierBadge(tier: .d)
    }
    .padding()
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
