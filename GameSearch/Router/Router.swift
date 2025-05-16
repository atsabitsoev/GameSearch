//
//  Router.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import Foundation

final class Router: ObservableObject {
    @Published var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func reset() {
        path = []
    }
}
