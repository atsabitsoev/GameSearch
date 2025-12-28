//
//  Article.swift
//  GameSearch
//
//  Created by Ацамаз on 01.11.2025.
//

import Foundation


struct Article: Identifiable {
    let id: String
    let title: String
    let date: Date
    var imageUrl: URL?
    let type: ArticleType?
    let slug: String
    var dataBlocks: [ArticleDataBlock]
}
