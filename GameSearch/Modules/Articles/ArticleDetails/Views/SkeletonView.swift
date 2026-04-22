//
//  SkeletonView.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 20.04.2026.
//

import SwiftUI


struct ArticleBlockSkeletonView: View {
    enum Kind {
        case title
        case paragraph
        case media
    }

    let kind: Kind
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        Group {
            switch kind {
            case .title:
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.34))
                    .frame(height: 24)
            case .paragraph:
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.26))
                        .frame(height: 20)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.22))
                        .frame(width: 220, height: 12)
                }
            case .media:
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.27))
                    .frame(height: 200)
            }
        }
        .overlay {
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.06), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: proxy.size.width * 0.28)
                    .offset(x: proxy.size.width * shimmerOffset)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.2
            }
        }
    }
}
