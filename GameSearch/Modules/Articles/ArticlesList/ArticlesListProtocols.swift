//
//  ArticlesListProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import Combine

protocol ArticlesListViewModelProtocol: ObservableObject {
    var articles: [Article] { get }
    
    func loadArticles() async
    func loadNextPage()
    func onCellTap(_ article: Article, router: ArticlesRouter)
}


protocol ArticlesListInteractorProtocol {
    func fetchArticles(page: Int) -> AnyPublisher<[Article], any Error>
}
