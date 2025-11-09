//
//  NewsListCell.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import SwiftUI


struct NewsListCell: View {
    let data: News
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: data.imageUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                placeholderImage
            }
            .frame(height: 150)
            .clipped()
            .cornersRadius(16)
            
            Text(data.title)
                .font(EAFont.info)
                .foregroundStyle(EAColor.textPrimary)
                .padding(.horizontal, 16)
            
            HStack {
                Text(setupDate(for: data.date))
                    .font(EAFont.infoSmall)
                    .foregroundStyle(EAColor.textSecondary)
                Spacer()
                articleTypeLogo
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(data.type == .dota2 ? EAColor.dotaColor.opacity(0.3) : data.type == .cs2 ? EAColor.csColor.opacity(0.3) : EAColor.info1)
        .cornerRadius(16)
        .shadow(color: EAColor.secondaryBackground, radius: 8, x: 0, y: 2)
    }
}


private extension NewsListCell {
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
        RoundedRectangle(cornerRadius: 12)
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
        let now = Date()

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
}
