//
//  Router.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import Foundation

final class ClubsRouter: ObservableObject {
    @Published var path: [ClubsRoute] = []

    func push(_ route: ClubsRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func reset() {
        path = []
    }
}

final class ArticlesRouter: ObservableObject {
    @Published var path: [ArticlesRoute] = []

    func push(_ route: ArticlesRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func reset() {
        path = []
    }
}
