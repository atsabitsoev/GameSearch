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

    // MARK: - Tournaments (legacy placeholder + Phase 1 stubs)

    func makeTournamentsView() -> some View {
        TournamentsPlaceholderView()
    }

    @MainActor
    func makeTournamentsListView() -> some View {
        // Phase 1 will replace this with a real TournamentsListView that
        // consumes `tournamentsService` and `matchesService`.
        TournamentsPlaceholderView()
    }

    @MainActor
    func makeTournamentDetailsView(idOrSlug: String) -> some View {
        TournamentsPhasePlaceholder(title: "Турнир \(idOrSlug)")
    }

    @MainActor
    func makeMatchDetailsView(id: MatchId) -> some View {
        TournamentsPhasePlaceholder(title: "Матч \(id)")
    }
}

// MARK: - Placeholder

private struct TournamentsPhasePlaceholder: View {
    let title: String

    var body: some View {
        ZStack {
            EAColor.background.ignoresSafeArea()
            VStack(spacing: 12) {
                Text(title)
                    .font(EAFont.header)
                    .foregroundStyle(EAColor.textPrimary)
                Text("Этот экран появится в Phase 1")
                    .font(EAFont.info)
                    .foregroundStyle(EAColor.textSecondary)
            }
            .padding()
        }
    }
}
