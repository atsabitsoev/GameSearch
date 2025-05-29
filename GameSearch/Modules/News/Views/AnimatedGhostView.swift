//
//  AnimatedGhostView.swift
//  GameSearch
//
//  Created by Ацамаз on 29.05.2025.
//

import SwiftUI


struct AnimatedGhostView: View {
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var isMoving = true
    @State private var direction: CGFloat = 1 // 1 для движения вправо, -1 для влево
    private let range: CGFloat = 100 // диапазон движения влево-вправо
    private let speed: CGFloat = 1.0 // скорость движения
    private let jumpHeight: CGFloat = -100 // высота прыжка
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.yellow)
                .frame(width: 30, height: 30)
            Image("ghost")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(EAColor.infoMain)
                .shadow(color: offsetY != 0 ? Color.red : .clear, radius: 10)
        }
        .offset(x: offsetX, y: offsetY)
        .onAppear {
            startMovement()
        }
        .onTapGesture {
            jump()
        }
        
    }
    
    private func startMovement() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            withAnimation(.linear(duration: 2)) {
                // Движение влево-вправо
                offsetX += direction * speed
                
                // Проверка границ и смена направления
                if offsetX > range {
                    direction = -1
                } else if offsetX < -range {
                    direction = 1
                }
                
                // Гравитация для прыжка
                if offsetY < 0 {
                    offsetY += 4 // сила гравитации
                } else {
                    offsetY = 0 // остановка на "земле"
                }
            }
        }
    }
    
    private func jump() {
        withAnimation(.easeOut(duration: 2)) {
            offsetY = jumpHeight
        }
    }
}



#Preview {
    GhostHeader()
        .background(EAColor.background)
}
