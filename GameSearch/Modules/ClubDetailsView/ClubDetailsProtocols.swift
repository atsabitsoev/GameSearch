//
//  ClubDetailsProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 20.05.2025.
//

import Foundation
import Combine


protocol ClubDetailsInteractorProtocol {
}

protocol ClubDetailsViewModelProtocol: ObservableObject {
    var sectionPickerState: DetailsSection { get set }
    var output: ClubDetailsVMOutput? { get set }
    var selectedSpecId: UUID? { get set }
}
