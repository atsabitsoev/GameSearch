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

protocol ArticlesListViewModelProtocol: ObservableObject {
    var articles: [Article] { get }
    var selectedFilter: ArticlesFilter { get set }
    var isLoadingNextPage: Bool { get }
    var state: ArticlesListState { get }
    
    func loadArticles() async
    func loadNextPage()
    func onItemAppear(_ article: Article)
    func onFilterSelect(_ filter: ArticlesFilter)
    func onCellTap(_ article: Article, router: ArticlesRouter)
}


protocol ArticlesListInteractorProtocol {
    func fetchArticles(page: Int) -> AnyPublisher<[Article], any Error>
}
