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
    @State private var refreshChip: RefreshChip = .none

    private enum RefreshChip {
        case none
        case success
        case failure
    }


    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }


    var body: some View {
        ZStack {
            EAColor.background
                .ignoresSafeArea()

            contentView
        }
        .navigationTitle("Новости")
        .navigationBarTitleDisplayMode(.automatic)
        .task {
            await viewModel.onAppear()
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
            articlesContentView
        case .empty:
            emptyStateView
        case .error(let message):
            errorStateView(message: message)
        }
    }

    var articlesContentView: some View {
        VStack(spacing: 0) {
            filtersHeader
                .background(EAColor.background)

            articlesList
                .overlay(alignment: .top) {
                    floatingChipOverlay
                        .padding(.top, 4)
                        .animation(.easeOut(duration: 0.2), value: viewModel.filteredPendingCount)
                        .animation(.easeOut(duration: 0.2), value: refreshChip)
                }
        }
    }

    var filtersHeader: some View {
        ArticlesFiltersView(
            selectedFilter: viewModel.selectedFilter,
            onSelect: { filter in
                withAnimation(.easeOut(duration: 0.2)) {
                    viewModel.onFilterSelect(filter)
                }
                scrollToTopToggle.toggle()
            }
        )
        .padding(.bottom, 10)
    }

    var articlesList: some View {
        ScrollViewReader { proxy in
            List {
                listCellsView
            }
            .listStyle(.plain)
            .listRowSpacing(12)
            .refreshable {
                await refreshArticles()
            }
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

    @ViewBuilder
    var floatingChipOverlay: some View {
        if viewModel.filteredPendingCount > 0 {
            showNewButton
        } else {
            switch refreshChip {
            case .success:
                refreshedChip
                    .allowsHitTesting(false)
            case .failure:
                refreshFailedChip
                    .allowsHitTesting(false)
            case .none:
                EmptyView()
            }
        }
    }

    var showNewButton: some View {
        Button {
            withAnimation(.easeOut(duration: 0.25)) {
                viewModel.revealPendingArticles()
            }
            scrollToTopToggle.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up")
                    .font(EAFont.infoSmall)
                    .accessibilityHidden(true)
                Text("Показать новое (\(viewModel.filteredPendingCount))")
                    .font(EAFont.infoSmall)
            }
            .foregroundStyle(EAColor.background)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(EAColor.accent)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Показать новое (\(viewModel.filteredPendingCount))"))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    var refreshedChip: some View {
        Text("Обновлено только что")
            .font(EAFont.infoSmall)
            .foregroundStyle(EAColor.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(EAColor.secondaryBackground.opacity(0.8))
            .clipShape(Capsule())
            .transition(.opacity.combined(with: .move(edge: .top)))
    }

    var refreshFailedChip: some View {
        Text("Не удалось обновить")
            .font(EAFont.infoSmall)
            .foregroundStyle(EAColor.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(EAColor.secondaryBackground.opacity(0.8))
            .clipShape(Capsule())
            .transition(.opacity.combined(with: .move(edge: .top)))
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
                    await viewModel.retry()
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
        let firstIdBefore = viewModel.articles.first?.id
        let succeeded = await viewModel.pullToRefresh()
        let firstIdAfter = viewModel.articles.first?.id
        let hasNewArticles = succeeded && firstIdBefore != firstIdAfter

        let nextChip: RefreshChip = succeeded ? .success : .failure
        let displayDuration: UInt64 = succeeded ? 1_600_000_000 : 2_500_000_000

        withAnimation(.easeOut(duration: 0.2)) {
            refreshChip = nextChip
        }

        if hasNewArticles {
            scrollToTopToggle.toggle()
        }

        Task {
            try? await Task.sleep(nanoseconds: displayDuration)
            await MainActor.run {
                guard refreshChip == nextChip else { return }
                withAnimation(.easeOut(duration: 0.2)) {
                    refreshChip = .none
                }
            }
        }
    }
}
