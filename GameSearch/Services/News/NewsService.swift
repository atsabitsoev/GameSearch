//
//  NewsService.swift
//  GameSearch
//
//  Created by Ацамаз on 01.11.2025.
//

import Foundation
import SwiftSoup
import Combine


protocol NewsServiceProtocol {
    func getLatestNews(page: Int) -> AnyPublisher<[News], any Error>
}


final class NewsService: NewsServiceProtocol {
    private let baseUrl: String = "https://cybersport.ru"
    
    
    /// page начинается с 0
    func getLatestNews(page: Int = 0) -> AnyPublisher<[News], any Error> {
            let limit = 30
            let offset = page * limit
            let urlString = "\(baseUrl)/api/materials?page[offset]=\(offset)&page[limit]=\(limit)&sort=-publishedAt"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Создаем и запускаем задачу
            return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .map { newsResponse in
                newsResponse.data
                    .map { item in
                        return News(
                            id: item.id,
                            title: item.attributes.title,
                            date: Date(timeIntervalSince1970: TimeInterval(item.attributes.publishedAt))
                        )
                    }
            }
            .eraseToAnyPublisher()
    }
}
