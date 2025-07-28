//
//  ClubListProtocols.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Combine
import CoreLocation


protocol ClubListViewModelProtocol: ObservableObject {
    var searchText: String { get set }
    var clubListCards: [ClubListCardData] { get }
    var mapClubs: [MapClubData] { get }
    var mapPopupClub: MapPopupData? { get set }
    var locationManager: LocationManager { get set }
    var filtersManager: FiltersManager { get set }
    var cameraRegion: CameraRegion { get set }
    var mapListButtonState: MapListButtonState { get set }
    var geoApplied: Bool { get }
    var isLoading: Bool { get }
    
    var showFiltersView: Bool { get set }
    
    func onGeoButtonTap()
    func onViewAppear()
    func onFiltersApply(_ filters: [ClubsFilter])
    func clearMapPopupClub()
    func routeToDetails(clubID: String, router: Router)
}


protocol ClubListInteractorProtocol {
    func fetchClubs(filters: [ClubsFilter], radius: QueryRadiusData) -> AnyPublisher<[FullClubData], any Error>
}
