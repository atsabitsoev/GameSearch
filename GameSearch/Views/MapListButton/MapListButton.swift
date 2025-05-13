//
//  MapListButton.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import SwiftUI

struct MapListButton: View {
    @Binding var buttonState: MapListButtonState
    
    var body: some View {
        Button {
            withAnimation {
                buttonState.toggle()
            }
        } label: {
            Label(
                buttonState.buttonData.title,
                systemImage: buttonState.buttonData.systemImage
            )
            .padding()
            .background(.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .circular
                )
            )
        }
        .buttonStyle(.automatic)
    }
}

#Preview {
    MapListButton(buttonState: .constant(.list))
}
