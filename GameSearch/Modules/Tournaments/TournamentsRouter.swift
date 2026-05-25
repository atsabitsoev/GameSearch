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

    /// One-shot hint set by deeplink handling (`gamesearch://tournaments/cs2`
    /// or `…/dota2`). `TournamentsListView` observes it on appear / on
    /// change and forwards to `viewModel.onSelectGame(_:)`. The view
    /// clears the value back to `nil` after consuming so a second
    /// observer-fire does not re-apply it.
    @Published var preselectedGame: Game?

    func push(_ route: TournamentsRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func reset() {
        path = []
    }

    /// Mark the preselected game as consumed by the view.
    func consumePreselectedGame() {
        preselectedGame = nil
    }
}
