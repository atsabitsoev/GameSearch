//
//  Route.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//



enum Route: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .details(let data):
            return hasher.combine(data.id)
        }
    }
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case let (.details(data1), .details(data2)): return data1.id == data2.id
        }
    }
    
    case details(ClubDetailsData)
}
