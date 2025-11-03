//
//  NewsListView.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import SwiftUI

struct NewsListView<ViewModel: NewsListViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    var body: some View {
        ZStack {
            EAColor.background
                .ignoresSafeArea()
            List(viewModel.news) { newsItem in
                NewsListCell(data: newsItem)
                    .listRowSeparator(.hidden)
                    .listRowBackground(EAColor.background)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            .listStyle(.plain)
            .listRowSpacing(16)
            .refreshable {
                await viewModel.loadNews()
            }
        }
        .toolbarBackground(EAColor.background, for: .navigationBar)
        .navigationTitle("Новости")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.loadNews()
            }
        }
    }
}
