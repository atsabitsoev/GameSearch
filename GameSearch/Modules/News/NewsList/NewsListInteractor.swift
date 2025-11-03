//
//  NewsListInteractor.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import Combine

final class NewsListInteractor: NewsListInteractorProtocol {
    let service: NewsServiceProtocol
    
    
    init(service: NewsServiceProtocol) {
        self.service = service
    }
    
    
    func fetchNews(page: Int) -> AnyPublisher<[News], any Error> {
        service.getLatestNews(page: page)
    }
}
