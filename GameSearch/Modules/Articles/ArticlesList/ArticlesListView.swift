//
//  ArticlesListView.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import SwiftUI

struct ArticlesListView<ViewModel: ArticlesListViewModelProtocol>: View {
    @EnvironmentObject private var router: ArticlesRouter
    @StateObject private var viewModel: ViewModel
    
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    var body: some View {
        ZStack {
            EAColor.background
                .ignoresSafeArea()
            List(viewModel.articles) { article in
                ArticlesListCell(data: article)
                    .listRowSeparator(.hidden)
                    .listRowBackground(EAColor.background)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .onTapGesture {
                        viewModel.onCellTap(article, router: router)
                    }
            }
            .listStyle(.plain)
            .listRowSpacing(16)
            .refreshable {
                await viewModel.loadArticles()
            }
        }
        .toolbarBackground(EAColor.background, for: .navigationBar)
        .navigationTitle("Новости")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadArticles()
        }
    }
}
