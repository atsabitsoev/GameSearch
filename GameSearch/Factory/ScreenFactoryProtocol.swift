//
//  ScreenFactoryProtocol.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI

protocol ScreenFactoryProtocol {
    associatedtype ClubList: View
    associatedtype ClubDetails: View

    associatedtype ArticlesList: View
    associatedtype ArticleDetails: View
    associatedtype Tournaments: View

    associatedtype TournamentsList: View
    associatedtype TournamentDetails: View
    associatedtype MatchDetails: View


    func makeClubListView() -> ClubList
    func makeClubDetailsView(_ data: ClubDetailsData) -> ClubDetails

    @MainActor
    func makeArticlesListView() -> ArticlesList
    func makeArticleDetailsView(data: ArticleDetailsVMInitData) -> ArticleDetails
    func makeTournamentsView() -> Tournaments

    @MainActor
    func makeTournamentsListView() -> TournamentsList
    @MainActor
    func makeTournamentDetailsView(idOrSlug: String) -> TournamentDetails
    @MainActor
    func makeMatchDetailsView(id: MatchId) -> MatchDetails
}
