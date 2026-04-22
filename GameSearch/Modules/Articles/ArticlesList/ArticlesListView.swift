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
    @State private var scrollToTopToggle = false
    @State private var showRefreshChip = false


    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }


    var body: some View {
        ZStack {
            EAColor.background
                .ignoresSafeArea()

            contentView
                .refreshable {
                    await refreshArticles()
                }
        }
        .navigationTitle("Новости")
        .navigationBarTitleDisplayMode(.automatic)
        .task {
            await viewModel.loadArticles()
        }
    }
}

private extension ArticlesListView {
    @ViewBuilder
    var contentView: some View {
        switch viewModel.state {
        case .loading:
            skeletonView
        case .content:
            articlesListView
        case .empty:
            emptyStateView
        case .error(let message):
            errorStateView(message: message)
        }
    }

    var articlesListView: some View {
        ScrollViewReader { proxy in
            List {
                Section {
                    listCellsView
                } header: {
                    filtersPinnedHeader
                }
            }
            .listStyle(.plain)
            .listRowSpacing(12)
            .onChange(of: scrollToTopToggle) {
                guard let firstId = viewModel.articles.first?.id else { return }
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo(firstId, anchor: .top)
                }
            }
        }
    }

    @ViewBuilder
    var listCellsView: some View {
        ForEach(viewModel.articles) { article in
            ArticlesListCell(
                data: article,
                style: article.id == viewModel.articles.first?.id ? .featured : .regular
            )
            .listRowSeparator(.hidden)
            .listRowBackground(EAColor.background)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .onTapGesture {
                viewModel.onCellTap(article, router: router)
            }
            .onAppear {
                viewModel.onItemAppear(article)
            }
        }
        if viewModel.isLoadingNextPage {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.vertical, 12)
            .listRowSeparator(.hidden)
            .listRowBackground(EAColor.background)
        }
    }

    var filtersPinnedHeader: some View {
        VStack(spacing: 8) {
            ArticlesFiltersView(
                selectedFilter: viewModel.selectedFilter,
                onSelect: { filter in
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.onFilterSelect(filter)
                    }
                    scrollToTopToggle.toggle()
                }
            )
            if showRefreshChip {
                Text("Обновлено только что")
                    .font(EAFont.infoSmall)
                    .foregroundStyle(EAColor.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(EAColor.secondaryBackground.opacity(0.8))
                    .clipShape(Capsule())
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
    }

    var skeletonView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ArticlesSkeletonCard(style: .featured)
                ForEach(0..<4, id: \.self) { _ in
                    ArticlesSkeletonCard(style: .regular)
                }
            }
            .padding(.top, 6)
            .padding(.horizontal, 16)
        }
    }

    var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "newspaper")
                .font(.system(size: 32))
                .foregroundStyle(EAColor.textSecondary)
            Text("Нет новостей")
                .font(EAFont.smallTitle)
                .foregroundStyle(EAColor.textPrimary)
            Text("Попробуйте другой фильтр или обновите список")
                .font(EAFont.infoSmall)
                .foregroundStyle(EAColor.textSecondary)
            if viewModel.selectedFilter != .all {
                Button("Сбросить фильтр") {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.onFilterSelect(.all)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(EAColor.secondaryBackground.opacity(0.8))
                .foregroundStyle(EAColor.textPrimary)
                .clipShape(Capsule())
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func errorStateView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundStyle(EAColor.textSecondary)
            Text(message)
                .font(EAFont.smallTitle)
                .foregroundStyle(EAColor.textPrimary)
            Button("Повторить") {
                Task {
                    await viewModel.loadArticles()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(EAColor.accent)
            .foregroundStyle(EAColor.background)
            .clipShape(Capsule())
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func refreshArticles() async {
        await viewModel.loadArticles()
        withAnimation(.easeOut(duration: 0.2)) {
            showRefreshChip = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.2)) {
                    showRefreshChip = false
                }
            }
        }
    }
}


