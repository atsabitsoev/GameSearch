//
//  ArticleDetailsVM.swift
//  GameSearch
//
//  Created by Ацамаз on 09.11.2025.
//

import Combine
import Foundation
import AnalyticsModule


enum ArticleDetailsVMInitData {
    case article(Article)
    case slug(String)
}


final class ArticleDetailsViewModel: ArticleDetailsViewModelProtocol {
    private let interactor: ArticleDetailsInteractorProtocol

    @Published var article: Article?
    @Published var isLoadingContent: Bool = true
    private var initingSlug: String?
    private var cancellables: [AnyCancellable] = []


    init(data: ArticleDetailsVMInitData, interactor: ArticleDetailsInteractorProtocol) {
        switch data {
        case .article(let article): self.article = article
        case .slug(let slug): self.initingSlug = slug
        }
        self.interactor = interactor
    }


    func onAppear() async {
        await loadArticle()

        sendOpenDetailAnalytics()
    }
}


private extension ArticleDetailsViewModel {
    @MainActor
    func loadArticle() async {
        guard let slug = article?.slug ?? initingSlug else { return }
        isLoadingContent = true
        await withCheckedContinuation { continuation in
            interactor.getArticle(slug: slug)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] _ in
                    self?.isLoadingContent = false
                    continuation.resume()
                }, receiveValue: { [weak self] article in
                    self?.article = article
                    self?.article?.dataBlocks = article.dataBlocks.clearLastHeaders()
                })
                .store(in: &cancellables)
        }
    }
}


//MARK: - Analytics

private extension ArticleDetailsViewModel {
    func sendOpenDetailAnalytics() {
        guard let article else { return }
        AppMetricaReporter.reportEvent(
            "news_detail_open",
            parameters: [
                "article_id": article.id,
                "slug": article.slug
            ]
        )
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
