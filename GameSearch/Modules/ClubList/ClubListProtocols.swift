//
//  ClubListProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Combine


protocol ClubListViewModelProtocol: ObservableObject {
    var searchText: String { get set }
    var clubs: [FullClubData] { get }
    var mapClubs: [MapClubData] { get }
    
    func onViewAppear() -> Void
}


protocol ClubListInteractorProtocol {
    func fetchClubs(filter: ClubsFilter?) -> AnyPublisher<[FullClubData], Error>
}

extension ClubListInteractorProtocol {
    func fetchClubs() -> AnyPublisher<[FullClubData], Error> {
        fetchClubs(filter: nil)
    }
}
