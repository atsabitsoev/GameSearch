//
//  Route.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//



enum ClubsRoute: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .details(let data):
            return hasher.combine(data.id)
        }
    }
    
    static func == (lhs: ClubsRoute, rhs: ClubsRoute) -> Bool {
        switch (lhs, rhs) {
        case let (.details(data1), .details(data2)): return data1.id == data2.id
        }
    }
    
    case details(ClubDetailsData)
}


enum ArticlesRoute: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .detailsByArticle(let data):
            return hasher.combine(data.id)
        case .detailsBySlug(let slug):
            return hasher.combine(slug)
        }
    }

    static func == (lhs: ArticlesRoute, rhs: ArticlesRoute) -> Bool {
        switch (lhs, rhs) {
        case let (.detailsByArticle(data1), .detailsByArticle(data2)): return data1.id == data2.id
        case let (.detailsBySlug(slug1), .detailsBySlug(slug2)): return slug1 == slug2
        default: return false
        }
    }

    case detailsByArticle(Article)
    case detailsBySlug(String)
}
