//
//  ClubMapAnnotation.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 15.05.2025.
//

import SwiftUI

struct ClubMapAnnotation: View {
    @State private var animation: Bool = false
    
    let clubMapName: String
    let didTapAction: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(EAColor.accent)
                    .frame(width: 25, height: 25)
                    .shadow(radius: 2)
                
                Image(systemName: "mappin.circle")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
            }
            .rotation3DEffect(
                Angle(degrees: animation ? 360 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .scaleEffect(animation ? 1.2 : 1.0)
            Text(clubMapName)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(EAColor.accent.opacity(0.9))
                        .shadow(radius: 2)
                )
                .offset(y: -5)
        }
        .onTapGesture {
            withAnimation {
                animation.toggle()
                didTapAction()
            }
        }
    }
}

///55.747731, 37.610834

#Preview {
    ClubMapAnnotation(clubMapName: "Collizeum", didTapAction: {})
}
