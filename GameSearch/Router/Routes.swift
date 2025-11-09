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
        case .details(let data):
            return hasher.combine(data.id)
        }
    }

    static func == (lhs: ArticlesRoute, rhs: ArticlesRoute) -> Bool {
        switch (lhs, rhs) {
        case let (.details(data1), .details(data2)): return data1.id == data2.id
        }
    }

    case details(Article)
}
