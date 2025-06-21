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
    var mapPopupClub: MapPopupData? { get set }
    
    func onViewAppear()
    func clearMapPopupClub()
    func routeToDetails(clubID: String, router: Router)
}


protocol ClubListInteractorProtocol {
    func fetchClubs(filter: ClubsFilter?) -> AnyPublisher<[FullClubData], Error>
}

extension ClubListInteractorProtocol {
    func fetchClubs() -> AnyPublisher<[FullClubData], Error> {
        fetchClubs(filter: nil)
    }
}
