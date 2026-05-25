//
//  PrizepoolLabel.swift
//  GameSearch
//
//  Renders a tournament prize pool with a money icon. Uses
//  `PrizepoolFormatter` for the actual string formatting.
//

import SwiftUI

struct PrizepoolLabel: View {
    let prizepool: Prizepool?

    var body: some View {
        if let prizepool {
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(EAFont.description)
                    .foregroundStyle(EAColor.yellow)
                Text(PrizepoolFormatter.formatted(prizepool))
                    .font(EAFont.infoBold)
                    .foregroundStyle(EAColor.yellow)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Призовой \(PrizepoolFormatter.formatted(prizepool))"))
        } else {
            EmptyView()
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        PrizepoolLabel(prizepool: Prizepool(amount: 1_250_000, currency: "United States Dollar"))
        PrizepoolLabel(prizepool: Prizepool(amount: 850_000, currency: "United States Dollar"))
        PrizepoolLabel(prizepool: Prizepool(amount: 5_000, currency: "United States Dollar"))
        PrizepoolLabel(prizepool: nil)
    }
    .padding()
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
