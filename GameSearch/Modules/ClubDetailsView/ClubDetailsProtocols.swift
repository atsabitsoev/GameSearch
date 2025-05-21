//
//  ClubDetailsProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 20.05.2025.
//

import Combine


protocol ClubDetailsInteractorProtocol {
}

protocol ClubDetailsViewModelProtocol: ObservableObject {
    var clubDetails: ClubDetailsData { get set }
    var sectionPickerState: DetailsSection { get set }
}
