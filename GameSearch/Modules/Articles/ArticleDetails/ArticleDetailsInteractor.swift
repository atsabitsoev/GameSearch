//
//  ArticleDetailsInteractor.swift
//  GameSearch
//
//  Created by Ацамаз on 09.11.2025.
//


import Combine


final class ArticleDetailsInteractor: ArticleDetailsInteractorProtocol {
    let service: ArticlesServiceProtocol


    init(service: ArticlesServiceProtocol) {
        self.service = service
    }


    func getArticleDataBlocks(slug: String) -> AnyPublisher<[ArticleDataBlock], any Error> {
        service.getArticleDataBlocks(slug: slug)
    }
}
