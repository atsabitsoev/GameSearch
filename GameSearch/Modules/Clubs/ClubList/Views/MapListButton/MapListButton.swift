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
            withAnimation(.spring(duration: 0.3)) {
                buttonState.toggle()
            }
        } label: {
            Label(
                buttonState.buttonData.title,
                systemImage: buttonState.buttonData.systemImage
            )
            .fontWeight(.bold)
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
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    MapListButton(buttonState: .constant(.list))
        .frame(width: 160, height: 48)
}
