//
//  ZoomAndPanImage.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 09.07.2025.
//

import SwiftUI


struct ZoomAndPanImage: View {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    let image: Image

    var body: some View {
        GeometryReader { geometry in
            let containerSize = geometry.size

            let imageSize = containerSize // Если изображение заполняет весь контейнер
            let maxX = (imageSize.width * scale - containerSize.width) / 2
            let maxY = (imageSize.height * scale - containerSize.height) / 2

            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(
                    x: max(min(offset.width, maxX), -maxX),
                    y: max(min(offset.height, maxY), -maxY)
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = (lastScale * value).clamped(to: 1...5)
                        }
                        .onEnded { _ in
                            lastScale = scale
                            if scale <= 1 {
                                // Возвращаем в центр
                                withAnimation {
                                    offset = .zero
                                    lastOffset = .zero
                                    scale = 1.0
                                    lastScale = 1.0
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            // Ограничиваем смещение при отпускании
                            let clampedX = max(min(offset.width, maxX), -maxX)
                            let clampedY = max(min(offset.height, maxY), -maxY)
                            offset = CGSize(width: clampedX, height: clampedY)
                            lastOffset = offset
                        }
                )
                .animation(.easeInOut, value: offset)
                .animation(.easeInOut, value: scale)
                .frame(width: containerSize.width, height: containerSize.height)
                .background(EAColor.background)
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

