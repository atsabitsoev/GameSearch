//
//  ScreenFactory.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI


final class ScreenFactory: ScreenFactoryProtocol {
    
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
}
