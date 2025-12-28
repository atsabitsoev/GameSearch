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


    func getArticle(slug: String) -> AnyPublisher<Article, any Error> {
        service.getArticle(slug: slug)
    }
}
