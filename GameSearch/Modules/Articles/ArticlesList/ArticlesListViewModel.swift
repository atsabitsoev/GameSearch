//
//  ArticlesListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import Combine
import Foundation

final class ArticlesListViewModel: ArticlesListViewModelProtocol {
    @Published var articles: [Article] = []
    @Published var selectedFilter: ArticlesFilter = .all
    @Published var isLoadingNextPage: Bool = false
    @Published var state: ArticlesListState = .loading
    
    private let interactor: ArticlesListInteractorProtocol
    private var cancellables: [AnyCancellable] = []
    private var allArticles: [Article] = []
    private var currentPage: Int = 0
    private var hasMorePages: Bool = true

    private let pageLimit = 30
    private let targetFilteredCount = 8
    private let preloadOffset = 3
    
    
    init(interactor: ArticlesListInteractorProtocol) {
        self.interactor = interactor
    }
    
    @MainActor
    func loadArticles() async {
        await withCheckedContinuation { continuation in
            state = .loading
            isLoadingNextPage = true
            hasMorePages = true
            currentPage = 0

            interactor.fetchArticles(page: 0)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoadingNextPage = false
                    if case .failure = completion, self?.articles.isEmpty == true {
                        self?.state = .error(message: "Не удалось загрузить новости")
                    }
                    continuation.resume()
                }, receiveValue: { [weak self] fetchedArticles in
                    guard let self else { return }
                    self.allArticles = self.removeDuplicatesById(fetchedArticles)
                    self.hasMorePages = !fetchedArticles.isEmpty
                    self.applyFilter()
                    self.updateState()
                })
                .store(in: &cancellables)
        }
    }
    
    func loadNextPage() {
        guard !isLoadingNextPage, hasMorePages else { return }

        isLoadingNextPage = true
        let nextPage = currentPage + 1
        interactor.fetchArticles(page: nextPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion, self?.articles.isEmpty == true {
                    self?.state = .error(message: "Не удалось загрузить новости")
                } else {
                    self?.updateState()
                    self?.isLoadingNextPage = false
                }
            }, receiveValue: { [weak self] fetchedArticles in
                guard let self else { return }
                self.currentPage = nextPage
                self.hasMorePages = !fetchedArticles.isEmpty
                self.allArticles = self.removeDuplicatesById(self.allArticles + fetchedArticles)
                self.applyFilter()
                self.updateState()
            })
            .store(in: &cancellables)
    }

    func onFilterSelect(_ filter: ArticlesFilter) {
        guard selectedFilter != filter else { return }
        selectedFilter = filter
        applyFilter()
        updateState()
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
    func applyFilter() {
        switch selectedFilter {
        case .all:
            articles = allArticles
        case .cs2:
            articles = allArticles.filter { $0.type == .cs2 }
        case .dota2:
            articles = allArticles.filter { $0.type == .dota2 }
        case .other:
            articles = allArticles.filter { $0.type == .other || $0.type == nil }
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
