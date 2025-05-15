//
//  ClubListProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Combine


protocol ClubListViewModelProtocol: ObservableObject {
    var searchText: String { get set }
    var clubListCards: [ClubListCardData] { get }
    var mapClubs: [MapClubData] { get }
    var destination: Destination? { get set }
    
    func onViewAppear() -> Void
    func routeToDetails(clubID: Int)
}


protocol ClubListInteractorProtocol {
    func fetchClubs(filter: ClubsFilter?) -> AnyPublisher<[FullClubData], Error>
}

extension ClubListInteractorProtocol {
    func fetchClubs() -> AnyPublisher<[FullClubData], Error> {
        fetchClubs(filter: nil)
    }
}
