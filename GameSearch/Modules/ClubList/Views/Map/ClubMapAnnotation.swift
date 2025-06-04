//
//  ClubMapAnnotation.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 15.05.2025.
//

import SwiftUI

struct ClubMapAnnotation: View {
    @State private var animation: Bool = false
    
    let clubMapName: String?
    let didTapAction: () -> Void


    init(clubMapName: String? = nil, didTapAction: @escaping () -> Void = {}) {
        self.clubMapName = clubMapName
        self.didTapAction = didTapAction
    }


    var body: some View {
        VStack {
            circleImageView
            annotationText
        }
        .onTapGesture {
            withAnimation {
                animation.toggle()
                didTapAction()
            }
        }
    }
}

private extension ClubMapAnnotation {
    var circleImageView: some View {
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
    }

    var annotationText: some View {
        Group {
            if let clubMapName {
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
        }
    }
}

#Preview {
    ClubMapAnnotation(clubMapName: "Collizeum", didTapAction: {})
}
