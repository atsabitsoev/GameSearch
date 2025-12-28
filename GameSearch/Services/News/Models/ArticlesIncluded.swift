//
//  ArticlesIncluded.swift
//  GameSearch
//
//  Created by Ацамаз on 28.12.2025.
//

struct ArticlesIncluded: Decodable {
    let id: String
    let attributes: Attributes

    struct Attributes: Decodable {
        let name: ArticleType?
    }
}

enum ArticleType: Decodable {
    case dota2
    case cs2
    case other

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case "Dota 2":
            self = .dota2
        case "CS2":
            self = .cs2
        default:
            self = .other
        }
    }
}
