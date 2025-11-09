//
//  ArticleDataBlock.swift
//  GameSearch
//
//  Created by Ацамаз on 09.11.2025.
//

import Foundation


enum ArticleDataBlock {
    case paragraph(ParagraphBlockData)
    case authoredQuote(AuthoredQuoteData)
}


struct ParagraphBlockData {
    let text: String
}

struct AuthoredQuoteData {
    let authorName: String
    let authorDescription: String
    let text: String
    let photo: URL?
}
