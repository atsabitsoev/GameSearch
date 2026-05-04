//
//  ArticleDetailsView.swift
//  GameSearch
//
//  Created by Ацамаз on 09.11.2025.
//

import SwiftUI


struct ArticleDetailsView<ViewModel: ArticleDetailsViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel


    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }


    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                articleHeaderView
                if viewModel.isLoadingContent {
                    blocksSkeletonView
                } else {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(viewModel.article?.dataBlocks ?? []) { dataBlock in
                            switch dataBlock.data {
                            case .paragraph(let paragraphData):
                                ParagraphView(text: paragraphData.text)
                            case .authoredQuote(let quoteData):
                                QuoteView(data: quoteData)
                            case .header(let headerData):
                                HeaderView(text: headerData.text)
                            case .list(let listData):
                                ListView(data: listData)
                            case .webRaw(let webRawData):
                                WebRawView(data: webRawData)
                                    .aspectRatio(16/9, contentMode: .fill)
                            case .gallery(let galleryData):
                                GalleryView(images: galleryData.images.map(\.absoluteString))
                            }
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom], 16)
        }
        .frame(maxWidth: .infinity)
        .background(EAColor.background)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                articleTypeLogo
            }
            if let slug = viewModel.article?.slug {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: URL(string: "https://gamesearchdeeplinkhosting.web.app/news/\(slug)")!) {
                        Label("", systemImage: "square.and.arrow.up")
                    }
                }
            }
        })
        .task {
            await viewModel.onAppear()
        }
    }
}


private extension ArticleDetailsView {
    var articleHeaderView: some View {
        VStack(alignment: .leading, spacing: 12) {
            coverImageView
            HStack(spacing: 8) {
                articleTypeBadge
                Text(formattedDate)
                    .font(EAFont.info)
                    .foregroundStyle(EAColor.textSecondary)
                Spacer()
            }
            Text(viewModel.article?.title ?? "")
                .font(EAFont.title)
                .foregroundStyle(EAColor.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var coverImageView: some View {
        GeometryReader { proxy in
            AsyncImage(url: viewModel.article?.imageUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(EAColor.info2.opacity(0.35))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundStyle(EAColor.textSecondary)
                    }
            }
            .frame(width: proxy.size.width, height: 220)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(height: 220)
    }

    @ViewBuilder
    var articleTypeBadge: some View {
        switch viewModel.article?.type {
        case .cs2:
            badgeView(
                text: "CS2",
                textColor: EAColor.csColor,
                backgroundColor: EAColor.csColor.opacity(0.18),
                borderColor: EAColor.csColor.opacity(0.35)
            )
        case .dota2:
            badgeView(
                text: "Dota 2",
                textColor: EAColor.dotaColor,
                backgroundColor: EAColor.dotaColor.opacity(0.18),
                borderColor: EAColor.dotaColor.opacity(0.35)
            )
        default:
            badgeView(
                text: "Материал",
                textColor: EAColor.textPrimary,
                backgroundColor: EAColor.secondaryBackground.opacity(0.7),
                borderColor: EAColor.textSecondary.opacity(0.28)
            )
        }
    }

    func badgeView(text: String, textColor: Color, backgroundColor: Color, borderColor: Color) -> some View {
        Text(text)
            .font(EAFont.infoBold)
            .foregroundStyle(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(Capsule())
    }

    var formattedDate: String {
        guard let date = viewModel.article?.date else { return "" }
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = .current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return "Сегодня в \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "HH:mm"
            return "Вчера в \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "d MMMM, HH:mm"
            return formatter.string(from: date)
        }
    }

    var blocksSkeletonView: some View {
        VStack(alignment: .leading, spacing: 12) {
            ArticleBlockSkeletonView(kind: .title)
            ForEach(0..<2, id: \.self) { index in
                ArticleBlockSkeletonView(kind: .paragraph)
            }
            ArticleBlockSkeletonView(kind: .media)
        }
    }

    @ViewBuilder
    var articleTypeLogo: some View {
        switch viewModel.article?.type {
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
}
