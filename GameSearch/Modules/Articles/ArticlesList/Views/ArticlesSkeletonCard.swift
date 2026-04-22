//
//  ArticlesSkeletonCard.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 17.04.2026.
//


import SwiftUI


private enum ArticlesSkeletonPalette {
    /// Нейтральные серые — скелетон не конкурирует с брендовыми цветами экрана.
    static let card = Color.gray.opacity(0.22)
    static let media = Color.gray.opacity(0.3)
    static let lineStrong = Color.gray.opacity(0.38)
    static let lineSoft = Color.gray.opacity(0.28)
    static let lineMuted = Color.gray.opacity(0.22)
    static let badge = Color.gray.opacity(0.34)
    static let shimmerHighlight = Color.white.opacity(0.06)
}


struct ArticlesSkeletonCard: View {
    enum LayoutStyle {
        case featured
        case regular
    }

    let style: LayoutStyle
    @State private var shimmerOffset: CGFloat = -1

    init(style: LayoutStyle = .regular) {
        self.style = style
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 16)
                .fill(ArticlesSkeletonPalette.media)
                .frame(height: style == .featured ? 160 : 120)
                .overlay(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(ArticlesSkeletonPalette.badge)
                        .frame(width: 62, height: 3)
                        .padding(12)
                }

            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(ArticlesSkeletonPalette.lineStrong)
                    .frame(height: style == .featured ? 16 : 14)
                RoundedRectangle(cornerRadius: 5)
                    .fill(ArticlesSkeletonPalette.lineSoft)
                    .frame(width: style == .featured ? 250 : 230, height: 12)

                HStack {
                    Capsule()
                        .fill(ArticlesSkeletonPalette.lineMuted)
                        .frame(width: 112, height: 20)
                    Spacer()
                    Circle()
                        .fill(ArticlesSkeletonPalette.lineSoft)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 9)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ArticlesSkeletonPalette.card)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(ArticlesSkeletonPalette.badge)
                .frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            GeometryReader { proxy in
                let width = proxy.size.width
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                ArticlesSkeletonPalette.shimmerHighlight,
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: width * 0.32)
                    .offset(x: width * shimmerOffset)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 3)
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.2
            }
        }
    }
}
