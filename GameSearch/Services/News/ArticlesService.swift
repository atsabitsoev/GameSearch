//
//  ArticlesService.swift
//  GameSearch
//
//  Created by Ацамаз on 01.11.2025.
//

import Foundation
import SwiftSoup
import Combine


protocol ArticlesServiceProtocol {
    func getLatestArticles(page: Int) -> AnyPublisher<[Article], any Error>
    func getArticleDataBlocks(slug: String) -> AnyPublisher<[ArticleDataBlock], any Error>
}


final class ArticlesService: ArticlesServiceProtocol {
    private let baseUrl: String = "https://cybersport.ru/api/materials"
    private let cardImageUrl = "https://images.cybersport.ru/images/material-card/plain/"
    private let quoteImageUrl = "https://images.cybersport.ru/images/quote-author/plain/"

    
    /// page начинается с 0
    func getLatestArticles(page: Int = 0) -> AnyPublisher<[Article], any Error> {
        let limit = 30
        let offset = page * limit
        let urlString = "\(baseUrl)?page[offset]=\(offset)&page[limit]=\(limit)&sort=-publishedAt"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Создаем и запускаем задачу
        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: request)
        return parsedArticlesListPublisher(dataTaskPublisher)
    }


    func getArticleDataBlocks(slug: String) -> AnyPublisher<[ArticleDataBlock], any Error> {
        let urlString = "\(baseUrl)/slug/\(slug)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: request)
        return parsedArticlePublisher(dataTaskPublisher)
    }
}


private extension ArticlesService {
    func parsedArticlesListPublisher(_ dataTaskPublisher: URLSession.DataTaskPublisher) -> AnyPublisher<[Article], any Error> {
        dataTaskPublisher
            .map(\.data)
            .decode(type: ArticlesListResponse.self, decoder: JSONDecoder())
            .map { [weak self] articlesResponse in
                return articlesResponse.data
                    .map { item in
                        let imageUrl: URL? = if let self, let imageUrlString = item.attributes.image {
                            URL(string: self.cardImageUrl + imageUrlString)
                        } else {
                            nil
                        }

                        let type = articlesResponse.included.first(where: {
                            $0.id == item.relationships.mainTag.data.id
                        })

                        return Article(
                            id: item.id,
                            title: item.attributes.title,
                            date: Date(timeIntervalSince1970: TimeInterval(item.attributes.publishedAt)),
                            imageUrl: imageUrl,
                            type: type?.attributes.name,
                            slug: item.attributes.slug,
                            dataBlocks: []
                        )
                    }
            }
            .eraseToAnyPublisher()
    }

    func parsedArticlePublisher(_ dataTaskPublisher: URLSession.DataTaskPublisher) -> AnyPublisher<[ArticleDataBlock], any Error> {
        dataTaskPublisher
            .map(\.data)
            .decode(type: ArticleResponse.self, decoder: JSONDecoder())
            .map { [weak self] articleResponse in
                guard let self else { return [] }
                return articleResponse.data.attributes.content.blocks
                    .compactMap { block in
                        switch block.type {
                        case .paragraph:
                            guard case .paragraph(let responseData) = block.data else { return nil }
                            let data = ParagraphBlockData(text: responseData.text.htmlToText())
                            return .paragraph(data)
                        case .authoredQuote:
                            guard case .authoredQuote(let responseData) = block.data else { return nil }
                            let data = AuthoredQuoteData(
                                authorName: responseData.name,
                                authorDescription: responseData.occupation,
                                text: responseData.text.htmlToText(),
                                photo: URL(string: self.quoteImageUrl + responseData.photo)
                            )
                            return .authoredQuote(data)
                        case .other:
                            return nil
                        }
                    }
            }
            .eraseToAnyPublisher()
    }
}
