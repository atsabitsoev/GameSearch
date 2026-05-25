//
//  ScoreView.swift
//  GameSearch
//
//  Renders a "left — right" score pair with optional winner highlighting.
//  Used in match cards and match details headers.
//

import SwiftUI

struct ScoreView: View {
    enum Side {
        case left, right, none
    }

    let leftScore: Int?
    let rightScore: Int?
    let winnerSide: Side
    var separator: String = "—"

    init(
        leftScore: Int?,
        rightScore: Int?,
        winnerSide: Side = .none,
        separator: String = "—"
    ) {
        self.leftScore = leftScore
        self.rightScore = rightScore
        self.winnerSide = winnerSide
        self.separator = separator
    }

    var body: some View {
        HStack(spacing: 6) {
            number(leftScore, isWinner: winnerSide == .left)
            Text(separator)
                .font(EAFont.infoBold)
                .foregroundStyle(EAColor.textSecondary)
            number(rightScore, isWinner: winnerSide == .right)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityLabel))
    }

    private func number(_ value: Int?, isWinner: Bool) -> some View {
        Text(value.map(String.init) ?? "—")
            .font(EAFont.infoBold)
            .foregroundStyle(isWinner ? EAColor.yellow : EAColor.textPrimary)
    }

    private var accessibilityLabel: String {
        let left = leftScore.map(String.init) ?? "нет данных"
        let right = rightScore.map(String.init) ?? "нет данных"
        return "Счёт: \(left) — \(right)"
    }
}

#Preview {
    VStack(spacing: 12) {
        ScoreView(leftScore: 1, rightScore: 0, winnerSide: .left)
        ScoreView(leftScore: 2, rightScore: 1, winnerSide: .left)
        ScoreView(leftScore: nil, rightScore: nil)
        ScoreView(leftScore: 16, rightScore: 14, winnerSide: .left, separator: ":")
    }
    .padding()
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
