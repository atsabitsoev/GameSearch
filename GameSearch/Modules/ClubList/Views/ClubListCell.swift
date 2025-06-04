//
//  ClubListCell.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import SwiftUI

struct ClubListCell: View {
    private let data: ClubListCardData
    
    init(data: ClubListCardData) {
        self.data = data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            topRow
            tagsRow
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(EAColor.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
        .shadow(color: EAColor.secondaryBackground, radius: 8, x: 0, y: 2)
    }
}

private extension ClubListCell {
    // MARK: - Top Row (Logo + Info)
    var topRow: some View {
        HStack(alignment: .top, spacing: 16) {
            clubLogo
            VStack(alignment: .leading, spacing: 4) {
                titleAndRating
                LocationLabel(address: data.addressString)
                    .font(EAFont.description)
                    .foregroundStyle(EAColor.textSecondary)
            }
        }
    }
    
    var clubLogo: some View {
        AsyncImage(url: URL(string: data.logo)) { image in
            image
                .resizable()
                .scaleEffect(CGSize(width: 1.1, height: 1.1))
                .aspectRatio(contentMode: .fill)
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 27))
        } placeholder: {
            RoundedRectangle(cornerRadius: 27)
                .fill(EAColor.background)
                .frame(width: 54, height: 54)
        }
    }
    
    var titleAndRating: some View {
        HStack(alignment: .top) {
            Text(data.name)
                .font(EAFont.title)
                .foregroundStyle(EAColor.textPrimary)
            Spacer()
            ratingView
        }
    }
    
    var ratingView: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "star.fill")
            Text(data.ratingString)
        }
        .foregroundStyle(EAColor.yellow)
        .font(EAFont.infoBig)
    }
    
    // MARK: - Tags Row (Price + Tags)
    var tagsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 8) {
                priceTag
                ForEach(data.tags, id: \.self) { tag in
                    TagView(tag: tag)
                }
            }
        }
        .scrollClipDisabled()
    }
    
    var priceTag: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 12)
                .fill(EAColor.infoMain)
            priceText
        }
        .frame(height: 32)
    }
    
    var priceText: some View {
        (Text("от ").font(EAFont.info) + Text(data.price).font(EAFont.infoBold) + Text(" ₽/час").font(EAFont.info))
            .foregroundStyle(EAColor.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
    }
}

private struct TagView: View {
    let tag: String
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 12)
                .fill(EAColor.info1)
            Text(tag)
                .font(EAFont.infoSmall)
                .foregroundStyle(EAColor.info2)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(height: 24)
    }
}

#Preview {
    ClubListCell(data: FullClubData.mock[0].getListCardData()).frame(height: 140).padding(.horizontal, 16)
}
