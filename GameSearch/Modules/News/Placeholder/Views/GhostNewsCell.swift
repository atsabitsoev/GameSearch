//
//  GhostNewsCell.swift
//  GameSearch
//
//  Created by Ацамаз on 29.05.2025.
//

import SwiftUI


struct GhostNewsCell: View {
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(EAColor.info2)
                .frame(height: 120)
                .overlay(
                    VStack {
                        Spacer()
                        Image(systemName: "newspaper")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(EAColor.textPrimary)
                        Spacer()
                    }
                )

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(EAColor.textPrimary.opacity(0.2))
                    .frame(width: 200, height: 12)

                RoundedRectangle(cornerRadius: 4)
                    .fill(EAColor.textPrimary.opacity(0.15))
                    .frame(width: 260, height: 10)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 220, height: 10)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
        .background(EAColor.info1)
        .cornerRadius(12)
        .shadow(color: EAColor.secondaryBackground, radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
