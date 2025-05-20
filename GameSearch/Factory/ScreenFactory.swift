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
}
