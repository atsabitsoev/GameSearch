//
//  ArticleDetailsVM.swift
//  GameSearch
//
//  Created by Ацамаз on 09.11.2025.
//

import Combine
import Foundation

final class ArticleDetailsViewModel: ArticleDetailsViewModelProtocol {
    private let interactor: ArticleDetailsInteractorProtocol

    @Published var article: Article
    private var cancellables: [AnyCancellable] = []


    init(article: Article, interactor: ArticleDetailsInteractorProtocol) {
        self.article = article
        self.interactor = interactor
    }


    func onAppear() async {
        await loadDataBlocks()
    }
}


private extension ArticleDetailsViewModel {
    func loadDataBlocks() async {
        await withCheckedContinuation { continuation in
            interactor.getArticleDataBlocks(slug: article.slug)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in continuation.resume() },
                      receiveValue: { [weak self] blocks in self?.article.dataBlocks = blocks.clearLastHeaders() })
                .store(in: &cancellables)
        }
    }
}


private extension Array where Element == ArticleDataBlock {
    func clearLastHeaders() -> [ArticleDataBlock] {
        var copy = self
        while let last = copy.last, last.type == .header {
            copy.removeLast()
        }
        return copy
    }
}
