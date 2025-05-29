//
//  GhostHeader.swift
//  GameSearch
//
//  Created by Ацамаз on 29.05.2025.
//

import SwiftUI


struct GhostHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            AnimatedGhostView()

            Text("Новости скоро будут!")
                .font(EAFont.title)
                .foregroundStyle(EAColor.textPrimary)

            Text("Заходите позже, чтобы узнать последние обновления и сплетни в мире игр")
                .font(.subheadline)
                .foregroundColor(EAColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 16)
    }
}


#Preview {
    GhostHeader()
}
