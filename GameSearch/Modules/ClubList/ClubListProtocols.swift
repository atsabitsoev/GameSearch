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
    func onScrollToEnd(with cardID: String)
    func clearMapPopupClub()
    func routeToDetails(clubID: String, router: Router)
}


protocol ClubListInteractorProtocol {
    func fetchFirstPageClubs(filter: ClubsFilter?) -> AnyPublisher<PaginatedResult<FullClubData>, any Error>
    func fetchNextPageClubs(filter: ClubsFilter?, paginationState: PaginationState) -> AnyPublisher<PaginatedResult<FullClubData>, any Error>
}

extension ClubListInteractorProtocol {
    func fetchFirstPageClubs() -> AnyPublisher<PaginatedResult<FullClubData>, any Error> {
        fetchFirstPageClubs(filter: nil)
    }
    
    func fetchNextPageClubs(paginationState: PaginationState) -> AnyPublisher<PaginatedResult<FullClubData>, any Error> {
        fetchNextPageClubs(filter: nil, paginationState: paginationState)
    }
}
