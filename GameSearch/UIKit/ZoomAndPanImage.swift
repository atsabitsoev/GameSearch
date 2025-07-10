//
//  ZoomAndPanImage.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 09.07.2025.
//

import SwiftUI


struct ZoomAndPanImage: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var swipeOffset: CGFloat = 0.0
    
    let image: Image

    var body: some View {
        GeometryReader { geometry in
            let containerSize = geometry.size
            
            let maxX = (containerSize.width * scale - containerSize.width) / 2
            let maxY = (containerSize.height * scale - containerSize.height) / 2
            
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(
                    x: max(min(offset.width, maxX), -maxX),
                    y: max(min(offset.height + swipeOffset, maxY), -maxY)
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = (lastScale * value).clamped(to: 1...5)
                        }
                        .onEnded { _ in
                            lastScale = scale
                            if scale <= 1 {
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
                            // Вертикальный свайп вниз
                            if abs(value.translation.height) > abs(value.translation.width) && scale <= 1.01 {
                                swipeOffset = max(value.translation.height, 0)
                            } else {
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                        }
                        .onEnded { value in
                            if swipeOffset > 150 {
                                // Если свайп длинный — закрываем
                                withAnimation {
                                    dismiss()
                                }
                            } else {
                                // Иначе возвращаемся
                                withAnimation {
                                    swipeOffset = 0
                                }
                                lastOffset = offset
                            }
                        }
                )
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

