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
            VStack(spacing: 24) {
                titleView
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.article.dataBlocks) { dataBlock in
                        switch dataBlock.data {
                        case .paragraph(let paragraphData):
                            ParagraphView(text: paragraphData.text)
                        case .authoredQuote(let quoteData):
                            QuoteView(data: quoteData)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .background(EAColor.background)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                articleTypeLogo
            }
        })
        .task {
            await viewModel.onAppear()
        }
    }
}


private extension ArticleDetailsView {
    var titleView: some View {
        Text(viewModel.article.title)
            .font(EAFont.title)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var articleTypeLogo: some View {
        switch viewModel.article.type {
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
