//
//  ScreenFactory.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUICore


final class ScreenFactory: ScreenFactoryProtocol {
    func makeClubListView() -> some View {
        let interactor = ClubListInteractor()
        let viewModel = ClubListViewModel(interactor: interactor)
        return ClubListView(viewModel: viewModel)
    }
}
