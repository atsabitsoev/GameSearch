//
//  HeaderView.swift
//  GameSearch
//
//  Created by Ацамаз on 14.12.2025.
//

import SwiftUI

struct HeaderView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle()
                .fill(EAColor.textSecondary.opacity(0.25))
                .frame(height: 10)
            Text(text)
                .font(EAFont.header)
                .foregroundStyle(EAColor.textPrimary)
        }
        .padding(.top, 4)
    }
}

