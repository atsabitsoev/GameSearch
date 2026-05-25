//
//  ScreenFactory.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI


final class ScreenFactory: ScreenFactoryProtocol {

    // MARK: - Shared Tournaments dependencies

    private let pandaScoreAPIClient: PandaScoreAPIClientProtocol
    private let tournamentsCacheStore: CacheStoreProtocol
    private let tournamentsService: TournamentsServiceProtocol
    private let matchesService: MatchesServiceProtocol

    // MARK: - Init

    init() {
        let apiClient = PandaScoreAPIClient()
        let cacheStore = CacheStore()
        self.pandaScoreAPIClient = apiClient
        self.tournamentsCacheStore = cacheStore
        self.tournamentsService = TournamentsService(api: apiClient, cache: cacheStore)
        self.matchesService = MatchesService(api: apiClient, cache: cacheStore)
    }

    // MARK: - Clubs

    func makeClubListView() -> some View {
        let interactor = ClubListInteractor()
        let viewModel = ClubListViewModel(interactor: interactor)
        return ClubListView(viewModel: viewModel)
    }

    func makeClubDetailsView(_ data: ClubDetailsData) -> some View {
        let interactor = ClubDetailsInteractor()
        let viewModel = ClubDetailsViewModel(data: data, interactor: interactor)
        return ClubDetailsView(viewModel: viewModel)
    }

    // MARK: - Articles

    @MainActor
    func makeArticlesListView() -> some View {
        let articlesService: ArticlesServiceProtocol = ArticlesService()
        let interactor: ArticlesListInteractorProtocol = ArticlesListInteractor(service: articlesService)
        let viewModel: some ArticlesListViewModelProtocol = ArticlesListViewModel(interactor: interactor)
        return ArticlesListView(viewModel: viewModel)
    }

    func makeArticleDetailsView(data: ArticleDetailsVMInitData) -> some View {
        let articlesService: ArticlesServiceProtocol = ArticlesService()
        let interactor: ArticleDetailsInteractorProtocol = ArticleDetailsInteractor(service: articlesService)
        let viewModel: some ArticleDetailsViewModelProtocol = ArticleDetailsViewModel(data: data, interactor: interactor)
        return ArticleDetailsView(viewModel: viewModel)
    }

    // MARK: - Tournaments

    @MainActor
    func makeTournamentsView() -> some View {
        makeTournamentsListView()
    }

    @MainActor
    func makeTournamentsListView() -> some View {
        let interactor = TournamentsListInteractor(
            tournamentsService: tournamentsService,
            matchesService: matchesService,
            cache: tournamentsCacheStore
        )
        let viewModel = TournamentsListViewModel(interactor: interactor)
        return TournamentsListView(viewModel: viewModel)
    }

    @MainActor
    func makeTournamentDetailsView(idOrSlug: String) -> some View {
        let interactor = TournamentDetailsInteractor(
            tournamentsService: tournamentsService,
            matchesService: matchesService,
            cache: tournamentsCacheStore
        )
        let viewModel = TournamentDetailsViewModel(
            idOrSlug: idOrSlug,
            interactor: interactor
        )
        return TournamentDetailsView(viewModel: viewModel)
    }

    @MainActor
    func makeMatchDetailsView(id: MatchId) -> some View {
        let interactor = MatchDetailsInteractor(
            matchesService: matchesService,
            tournamentsService: tournamentsService,
            cache: tournamentsCacheStore
        )
        let viewModel = MatchDetailsViewModel(
            matchId: id,
            interactor: interactor
        )
        return MatchDetailsView(viewModel: viewModel)
    }
}
