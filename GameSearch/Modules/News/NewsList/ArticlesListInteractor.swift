//
//  ArticlesListInteractor.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import Combine

final class ArticlesListInteractor: ArticlesListInteractorProtocol {
    let service: ArticlesServiceProtocol
    
    
    init(service: ArticlesServiceProtocol) {
        self.service = service
    }
    
    
    func fetchArticles(page: Int) -> AnyPublisher<[Article], any Error> {
        service.getLatestArticles(page: page)
    }

    func getArticleDataBlocks(slug: String) -> AnyPublisher<[ArticleDataBlock], any Error> {
        service.getArticleDataBlocks(slug: slug)
    }
}
