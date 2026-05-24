//
//  ArticlesListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import Combine
import Foundation

@MainActor
final class ArticlesListViewModel: ArticlesListViewModelProtocol {
    @Published var articles: [Article] = []
    @Published var pendingNewArticles: [Article] = []
    @Published var selectedFilter: ArticlesFilter = .all
    @Published var isLoadingNextPage: Bool = false
    @Published var state: ArticlesListState = .loading

    private let interactor: ArticlesListInteractorProtocol
    private var allArticles: [Article] = []
    private var loadedOffset: Int = 0
    private var hasMorePages: Bool = true
    private var hasLoadedOnce: Bool = false

    /// Монотонно растущий счётчик. Используется, чтобы поздний ответ устаревшего
    /// запроса не перетёр данные, обновлённые более свежим запросом.
    private var refreshGeneration: UInt64 = 0
    private var paginationGeneration: UInt64 = 0

    private let pageLimit = 30
    private let targetFilteredCount = 8
    private let preloadOffset = 3

    var filteredPendingCount: Int {
        filter(pendingNewArticles, by: selectedFilter).count
    }

    init(interactor: ArticlesListInteractorProtocol) {
        self.interactor = interactor
    }

    func onAppear() async {
        if hasLoadedOnce {
            _ = await performSilentRefresh(autoReveal: false)
        } else {
            _ = await performInitialLoad()
        }
    }

    func pullToRefresh() async -> Bool {
        if hasLoadedOnce {
            return await performSilentRefresh(autoReveal: true)
        } else {
            return await performInitialLoad()
        }
    }

    func retry() async {
        _ = await performInitialLoad()
    }

    func revealPendingArticles() {
        guard !pendingNewArticles.isEmpty else { return }
        let revealedCount = pendingNewArticles.count
        allArticles = removeDuplicatesById(pendingNewArticles + allArticles)
        pendingNewArticles = []
        loadedOffset += revealedCount
        recomputeArticles()
    }

    func loadNextPage() {
        guard !isLoadingNextPage, hasMorePages else { return }

        isLoadingNextPage = true
        let requestedOffset = loadedOffset
        paginationGeneration &+= 1
        let generation = paginationGeneration

        Task { [weak self] in
            guard let self else { return }
            do {
                let fetched = try await self.fetchPage(offset: requestedOffset)
                guard generation == self.paginationGeneration else { return }
                self.applyNextPageResult(fetched, requestedOffset: requestedOffset)
            } catch {
                guard generation == self.paginationGeneration else { return }
                if self.articles.isEmpty {
                    self.state = .error(message: "Не удалось загрузить новости")
                }
                self.isLoadingNextPage = false
            }
        }
    }

    func onFilterSelect(_ filter: ArticlesFilter) {
        guard selectedFilter != filter else { return }
        selectedFilter = filter
        recomputeArticles()
    }

    func onCellTap(_ article: Article, router: ArticlesRouter) {
        router.push(.detailsByArticle(article))
    }

    func onItemAppear(_ article: Article) {
        guard let index = articles.firstIndex(where: { $0.id == article.id }) else { return }
        let thresholdIndex = max(articles.count - preloadOffset, 0)
        if index >= thresholdIndex {
            loadNextPage()
        }
    }
}

private extension ArticlesListViewModel {
    func performInitialLoad() async -> Bool {
        state = .loading
        isLoadingNextPage = true
        hasMorePages = true
        loadedOffset = 0
        pendingNewArticles = []

        refreshGeneration &+= 1
        let generation = refreshGeneration

        do {
            let fetched = try await fetchPage(offset: 0)
            guard generation == refreshGeneration else { return false }
            allArticles = removeDuplicatesById(fetched)
            hasMorePages = fetched.count >= pageLimit
            loadedOffset = allArticles.count
            recomputeArticles()
            hasLoadedOnce = true
            isLoadingNextPage = false
            return true
        } catch {
            guard generation == refreshGeneration else { return false }
            isLoadingNextPage = false
            if articles.isEmpty {
                state = .error(message: "Не удалось загрузить новости")
            }
            return false
        }
    }

    func performSilentRefresh(autoReveal: Bool) async -> Bool {
        refreshGeneration &+= 1
        let generation = refreshGeneration

        do {
            let fetched = try await fetchPage(offset: 0)
            guard generation == refreshGeneration else { return false }

            let existingIds = Set(allArticles.map(\.id))
            let newOnes = fetched.filter { !existingIds.contains($0.id) }
            guard !newOnes.isEmpty else { return true }

            if autoReveal {
                allArticles = removeDuplicatesById(newOnes + allArticles)
                pendingNewArticles = []
                loadedOffset += newOnes.count
                recomputeArticles()
            } else {
                let pendingIds = Set(pendingNewArticles.map(\.id))
                let merged = pendingNewArticles + newOnes.filter { !pendingIds.contains($0.id) }
                pendingNewArticles = merged
            }
            return true
        } catch {
            return false
        }
    }

    /// Берёт первое (и единственное в логике сервиса) значение Combine-публикации,
    /// чтобы использовать его в async/await без `CheckedContinuation` и cancellables.
    func fetchPage(offset: Int) async throws -> [Article] {
        for try await page in interactor.fetchArticles(offset: offset, limit: pageLimit).values {
            return page
        }
        return []
    }

    func applyNextPageResult(_ fetched: [Article], requestedOffset: Int) {
        hasMorePages = fetched.count >= pageLimit
        let beforeCount = allArticles.count
        allArticles = removeDuplicatesById(allArticles + fetched)
        let appended = allArticles.count - beforeCount
        loadedOffset = requestedOffset + appended
        recomputeArticles()
        isLoadingNextPage = false
    }

    func recomputeArticles() {
        applyFilter()
        updateState()
    }

    func applyFilter() {
        articles = filter(allArticles, by: selectedFilter)
    }

    func filter(_ source: [Article], by filter: ArticlesFilter) -> [Article] {
        switch filter {
        case .all:
            return source
        case .cs2:
            return source.filter { $0.type == .cs2 }
        case .dota2:
            return source.filter { $0.type == .dota2 }
        case .other:
            return source.filter { $0.type == .other || $0.type == nil }
        }
    }

    func updateState() {
        if articles.isEmpty {
            if hasMorePages, selectedFilter != .all {
                state = .loading
                loadMoreForFilterIfNeeded()
            } else {
                state = .empty
            }
        } else {
            state = .content
        }
    }

    func loadMoreForFilterIfNeeded() {
        guard selectedFilter != .all else { return }
        guard articles.count < targetFilteredCount else { return }
        guard hasMorePages, !isLoadingNextPage else { return }
        loadNextPage()
    }

    func removeDuplicatesById(_ articles: [Article]) -> [Article] {
        var seenIds = Set<String>()
        return articles.filter { article in
            seenIds.insert(article.id).inserted
        }
    }
}
