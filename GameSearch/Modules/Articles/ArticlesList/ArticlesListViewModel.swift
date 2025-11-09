//
//  ArticlesListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 03.11.2025.
//

import Combine
import Foundation

final class ArticlesListViewModel: ArticlesListViewModelProtocol {
    @Published var articles: [Article] = []
    
    private let interactor: ArticlesListInteractorProtocol
    private var cancellables: [AnyCancellable] = []
    
    
    init(interactor: ArticlesListInteractorProtocol) {
        self.interactor = interactor
    }
    
    
    func loadArticles() async {
        await withCheckedContinuation { continuation in
            interactor.fetchArticles(page: 0)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in continuation.resume() },
                      receiveValue: { [weak self] articles in self?.articles = articles })
                .store(in: &cancellables)
        }
    }
    
    func loadNextPage() {
        print("Не сделано")
    }

    func onCellTap(_ article: Article, router: ArticlesRouter) {
        router.push(.details(article))
    }
}
