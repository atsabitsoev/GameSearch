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
    let type: BlockType

    enum BlockType: String {
        case paragraph
        case authoredQuote
        case header
        case list
        case raw
        case other
    }

    enum Data {
        case paragraph(ParagraphBlockData)
        case authoredQuote(AuthoredQuoteData)
        case header(HeaderBlockData)
        case list(ListBlockData)
        case webRaw(WebRawBlockData)
        case gallery(GalleryBlockData)
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

struct WebRawBlockData {
    let html: String
}

struct GalleryBlockData {
    let images: [URL]
}
