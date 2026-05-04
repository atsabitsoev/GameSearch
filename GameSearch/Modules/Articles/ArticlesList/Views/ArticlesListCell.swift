//
//  ArticlesListCell.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import SwiftUI
import CachedAsyncImage


struct ArticlesListCell: View {
    enum LayoutStyle {
        case featured
        case regular
    }

    let data: Article
    let style: LayoutStyle

    init(data: Article, style: LayoutStyle = .regular) {
        self.data = data
        self.style = style
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mediaView
            infoPanel
        }
        .background(EAColor.secondaryBackground.opacity(0.5))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(typeAccentColor)
                .frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 3)
    }
}


private extension ArticlesListCell {
    var mediaView: some View {
        CachedAsyncImage(url: data.imageUrl) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            placeholderImage
        }
        .frame(height: style == .featured ? 160 : 120)
        .clipped()
    }

    var infoPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(data.title)
                .font(style == .featured ? EAFont.infoTitle : EAFont.smallTitle)
                .foregroundStyle(EAColor.textPrimary)
                .lineLimit(style == .featured ? 3 : 2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 8) {
                datePill
                Spacer()
                articleTypeLogo
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    var datePill: some View {
        Text(setupDate(for: data.date))
            .font(EAFont.infoSmall)
            .foregroundStyle(EAColor.textPrimary)
            .padding(.vertical, 5)
    }

    @ViewBuilder
    var articleTypeLogo: some View {
        switch data.type {
        case .cs2: Image("cs")
                .resizable()
                .frame(width: 24, height: 24)
        case .dota2:
            Image("dota2")
                .resizable()
                .frame(width: 24, height: 24)
        default: EmptyView()
        }
    }

    var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(EAColor.info2)
            .overlay(
                VStack {
                    Spacer()
                    Image(systemName: "newspaper")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(EAColor.textPrimary)
                    Spacer()
                }
            )
    }
    
    func setupDate(for date: Date) -> String {
        let calendar = Calendar.current

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        if calendar.isDateInToday(date) {
            return "Сегодня в \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Вчера в \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "dd.MM в HH:mm"
            return formatter.string(from: date)
        }
    }

    var typeAccentColor: Color {
        switch data.type {
        case .dota2: EAColor.dotaColor
        case .cs2: EAColor.csColor
        default: EAColor.textSecondary
        }
    }
}
