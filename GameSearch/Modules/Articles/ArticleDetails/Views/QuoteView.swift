//
//  QuoteView.swift
//  GameSearch
//
//  Created by Ацамаз on 10.11.2025.
//

import SwiftUI

struct QuoteView: View {
    let data: AuthoredQuoteData


    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(EAColor.info1)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    roundImage
                    VStack(alignment: .leading, spacing: 0) {
                        nameView
                        opportunityView
                    }
                    Spacer()
                }
                quoteTextView
            }
            .padding(16)
        }
    }
}


private extension QuoteView {
    var roundImage: some View {
        AsyncImage(url: data.photo) { image in
            image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 48, height: 48)
        } placeholder: {
            EmptyView()
        }
    }

    var nameView: some View {
        Text(data.authorName)
            .font(EAFont.smallTitle)
    }

    @ViewBuilder
    var opportunityView: some View {
        if !data.authorDescription.isEmpty {
            Text(data.authorDescription)
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
        }
    }

    var quoteTextView: some View {
        Text(data.text)
            .font(.system(size: 16, weight: .regular))
            .italic()
    }
}
