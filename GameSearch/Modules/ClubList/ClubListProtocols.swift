//
//  ClubListProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Combine


protocol ClubListViewModelProtocol: ObservableObject {
    var searchText: String { get set }
    var clubs: [Club] { get }
    
    func onViewAppear() -> Void
}


protocol ClubListInteractorProtocol {
    func fetchClubs(filter: ClubsFilter?) -> AnyPublisher<[Club], Error>
}

extension ClubListInteractorProtocol {
    func fetchClubs() -> AnyPublisher<[Club], Error> {
        fetchClubs(filter: nil)
    }
}
