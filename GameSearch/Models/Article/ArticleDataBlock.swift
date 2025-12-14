//
//  ArticleDataBlock.swift
//  GameSearch
//
//  Created by Ацамаз on 09.11.2025.
//

import Foundation


struct ArticleDataBlock: Identifiable {
    let id: String
    let data: Data

    enum Data {
        case paragraph(ParagraphBlockData)
        case authoredQuote(AuthoredQuoteData)
        case header(HeaderBlockData)
        case list(ListBlockData)
    }
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

struct HeaderBlockData {
    let text: String
    let level: Int
}

struct ListBlockData {
    let items: [String]
}
