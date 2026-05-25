//
//  TournamentsRouter.swift
//  GameSearch
//
//  Navigation router for the Tournaments tab. Wired into the tab's
//  NavigationStack and into Deeplink handling.
//

import Foundation

final class TournamentsRouter: ObservableObject {
    @Published var path: [TournamentsRoute] = []

    func push(_ route: TournamentsRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func reset() {
        path = []
    }
}
