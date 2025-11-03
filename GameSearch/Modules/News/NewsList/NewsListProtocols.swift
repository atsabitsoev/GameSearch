//
//  NewsListProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import Combine

protocol NewsListViewModelProtocol: ObservableObject {
    var news: [News] { get }
    
    func loadNews() async
    func loadNextPage()
}


protocol NewsListInteractorProtocol {
    func fetchNews(page: Int) -> AnyPublisher<[News], any Error>
}
