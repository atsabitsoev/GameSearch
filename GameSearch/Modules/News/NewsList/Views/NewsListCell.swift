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
            .frame(height: 120)
            .clipped()
            .cornersRadius(top: 16, bottom: 16)
            
            Text(data.title)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .background(EAColor.info1)
        .cornerRadius(12)
        .shadow(color: EAColor.secondaryBackground, radius: 8, x: 0, y: 2)
    }
}


private extension NewsListCell {
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
}
