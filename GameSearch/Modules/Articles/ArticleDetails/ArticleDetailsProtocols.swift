//
//  ArticleDetailsProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 09.11.2025.
//

import Combine


protocol ArticleDetailsViewModelProtocol: ObservableObject {
    var article: Article { get }

    func onAppear() async
}


protocol ArticleDetailsInteractorProtocol {
    func getArticleDataBlocks(slug: String) -> AnyPublisher<[ArticleDataBlock], any Error>
}
