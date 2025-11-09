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
    func onCellTap(_ article: Article)
}


protocol ArticlesListInteractorProtocol {
    func fetchArticles(page: Int) -> AnyPublisher<[Article], any Error>
    func getArticleDataBlocks(slug: String) -> AnyPublisher<[ArticleDataBlock], any Error>
}
