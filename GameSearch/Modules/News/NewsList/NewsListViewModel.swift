//
//  NewsListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import Combine
import Foundation

final class NewsListViewModel: NewsListViewModelProtocol {
    @Published var news: [News] = []
    
    private let interactor: NewsListInteractorProtocol
    private var cancellables: [AnyCancellable] = []
    
    
    init(interactor: NewsListInteractorProtocol) {
        self.interactor = interactor
    }
    
    
    func loadNews() async {
        await withCheckedContinuation { continuation in
            interactor.fetchNews(page: 0)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in continuation.resume() },
                      receiveValue: { [weak self] news in self?.news = news })
                .store(in: &cancellables)
        }
    }
    
    func loadNextPage() {
        print("Не сделано")
    }
}
