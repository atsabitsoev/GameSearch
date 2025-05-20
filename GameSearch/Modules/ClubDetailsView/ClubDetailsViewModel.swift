//
//  ClubDetailsViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 20.05.2025.
//

import Combine


final class ClubDetailsViewModel: ObservableObject {
    private let interactor: ClubDetailsInteractorProtocol
    
    @Published private var clubDetails: ClubDetailsData?
    
    init(data: ClubDetailsData, interactor: ClubDetailsInteractorProtocol) {
        self.clubDetails = data
        self.interactor = interactor
    }
}
