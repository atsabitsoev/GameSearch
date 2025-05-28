//
//  ClubDetailsViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 20.05.2025.
//

import Combine


final class ClubDetailsViewModel: ClubDetailsViewModelProtocol {
    private let interactor: ClubDetailsInteractorProtocol
    
    @Published var clubDetails: ClubDetailsData
    @Published var sectionPickerState: DetailsSection = .common


    init(data: ClubDetailsData, interactor: ClubDetailsInteractorProtocol) {
        self.clubDetails = data
        self.interactor = interactor
    }
}
