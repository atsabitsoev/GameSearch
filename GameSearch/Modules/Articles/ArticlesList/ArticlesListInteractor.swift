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
    
    
    func fetchArticles(offset: Int, limit: Int) -> AnyPublisher<[Article], any Error> {
        service.getLatestArticles(offset: offset, limit: limit)
    }
}
