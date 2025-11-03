//
//  RadioButton.swift
//  GameSearch
//
//  Created by Ацамаз on 06.06.2025.
//

import SwiftUI


struct RadioButton: View {
    @Binding var isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(style: .init(lineWidth: 1))
                .foregroundStyle(isSelected ? EAColor.accent : EAColor.textSecondary)
                .background(Color.clear)
            if isSelected {
                Circle()
                    .padding(2)
                    .foregroundStyle(
                        RadialGradient(
                            colors: [Color.accentGradient, EAColor.accent],
                            center: .center,
                            startRadius: 0,
                            endRadius: 13
                        )
                    )
            }
        }
        .frame(width: 24, height: 24)
    }
}


#Preview {
    @Previewable @State var isSelected = true
    RadioButton(isSelected: $isSelected)
        .frame(width: 50, height: 50)
}
