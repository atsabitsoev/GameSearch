//
//  ArticlesListProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import Combine

enum ArticlesListState {
    case loading
    case content
    case empty
    case error(message: String)
}

@MainActor
protocol ArticlesListViewModelProtocol: ObservableObject {
    var articles: [Article] { get }
    var pendingNewArticles: [Article] { get }
    var filteredPendingCount: Int { get }
    var selectedFilter: ArticlesFilter { get set }
    var isLoadingNextPage: Bool { get }
    var state: ArticlesListState { get }

    func onAppear() async
    func pullToRefresh() async -> Bool
    func retry() async
    func revealPendingArticles()
    func loadNextPage()
    func onItemAppear(_ article: Article)
    func onFilterSelect(_ filter: ArticlesFilter)
    func onCellTap(_ article: Article, router: ArticlesRouter)
}


protocol ArticlesListInteractorProtocol {
    func fetchArticles(offset: Int, limit: Int) -> AnyPublisher<[Article], any Error>
}
