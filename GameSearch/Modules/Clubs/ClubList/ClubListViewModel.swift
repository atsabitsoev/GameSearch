//
//  ClubListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Foundation
import Combine
import CoreLocation

final class ClubListViewModel<Interactor: ClubListInteractorProtocol>: ClubListViewModelProtocol {
    private let interactor: Interactor
    
    @Published var searchText = ""
    @Published var filtersManager = FiltersManager()
    @Published private var clubs: [FullClubData] = []
    @Published var mapClubs: [MapClubData] = []
    @Published var clubListCards: [ClubListCardData] = []
    @Published var mapPopupClub: MapPopupData?
    @Published var isLoading = false
    @Published var locationManager = LocationManager()
    @Published var cameraRegion: CameraRegion = CameraRegion(center: CLLocationCoordinate2D(latitude: 55, longitude: 37), delta: CLLocationCoordinate2D(latitude: 0.1, longitude: 0.1))
    @Published var mapListButtonState: MapListButtonState = .list
    @Published var geoApplied: Bool = true
    
    @Published var showFiltersView: Bool = false
    
    private var shouldHideGeoButton = true
    private var lastSearchedText: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    
    init(interactor: Interactor) {
        self.interactor = interactor
        subscribeSearchText()
        subscribeFilters()
        subscribeCameraDelta()
        subscribeLocationAuth()
    }
    
    
    func onViewAppear() {
        locationManager.onLocationGot = { [weak self] in
            self?.loadWithDefaultDelta()
        }
        locationManager.onLocationChange = self.onLocationChange
    }
    
    func onFiltersApply(_ filters: [ClubsFilter]) {
        filtersManager.remakeFilters(filters)
    }
    
    func routeToDetails(clubID: String, router: Router) {
        guard let club = getClubDetails(by: clubID) else {
            print("Club not found, need delete from Base")
            return
        }
        router.push(.details(club))
    }
    
    func clearMapPopupClub() {
        mapPopupClub = nil
    }
    
    func onGeoButtonTap() {
        loadWithDefaultDelta()
        shouldHideGeoButton = true
    }
}


private extension ClubListViewModel {
    func subscribeSearchText() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] text in
                self?.searchTextChanged(text)
            }
            .store(in: &cancellables)
    }
    
    func subscribeFilters() {
        filtersManager.$filters
            .sink { [weak self] filters in
                guard self?.mapListButtonState == .list else {
                    self?.loadClubs(filters: filters)
                    return
                }
                if filters.isEmpty {
                    self?.setDefaultRegion()
                } else {
                    self?.setMediumRegion()
                }
                self?.loadClubs(filters: filters)
            }
            .store(in: &cancellables)
    }
    
    func subscribeCameraDelta() {
        $cameraRegion
            .removeDuplicates()
            .debounce(for: .milliseconds(700), scheduler: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.checkGeoButton()
                self?.loadClubs(filters: self?.filtersManager.filters ?? [])
            }
            .store(in: &cancellables)
    }
    
    func checkGeoButton() {
        if shouldHideGeoButton {
            geoApplied = true
        } else {
            let radius = QueryRadiusData(center: cameraRegion.center, delta: cameraRegion.delta)
            geoApplied = radius == defaultRadius()
        }
        shouldHideGeoButton = false
    }
    
    func subscribeLocationAuth() {
        locationManager.$locationAllowed
            .dropFirst()
            .sink { [weak self] allowed in
                if !allowed {
                    self?.loadWithDefaultDelta()
                }
            }
            .store(in: &cancellables)
    }
    
    func onLocationChange() {
        geoApplied = false
    }
    
    func loadWithDefaultDelta() {
        setDefaultRegion()
        loadClubs(filters: filtersManager.filters)
    }
    
    func setDefaultRegion() {
        let radius = defaultRadius()
        cameraRegion = .init(center: radius.center, delta: radius.delta)
    }
    
    func setMediumRegion() {
        cameraRegion = CameraRegion(center: cameraRegion.center, delta: CLLocationCoordinate2D(latitude: 0.2, longitude: 0.2))
    }
    
    func setBigRegion() {
        cameraRegion = CameraRegion(center: cameraRegion.center, delta: CLLocationCoordinate2D(latitude: 3, longitude: 3))
    }
    
    func defaultRadius() -> QueryRadiusData {
        guard let location = locationManager.location else {
            return QueryRadiusData(
                center: CLLocationCoordinate2D(latitude: 55.7482, longitude: 37.6210),
                delta: CLLocationCoordinate2D(latitude: 0.04, longitude: 0.04)
            )
        }
        return QueryRadiusData(
            center: location,
            delta: CLLocationCoordinate2D(latitude: 0.04, longitude: 0.04)
        )
    }
    
    func loadClubs(filters: [ClubsFilter]) {
        isLoading = true
        interactor.fetchClubs(filters: filters, radius: QueryRadiusData(center: cameraRegion.center, delta: cameraRegion.delta))
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] result in
                    self?.updateClubs(result)
                }
            )
            .store(in: &cancellables)
    }
    
    func searchTextChanged(_ searchText: String) {
        guard lastSearchedText != searchText else { return }
        lastSearchedText = searchText
        if searchText.isEmpty {
            setDefaultRegion()
            filtersManager.removeSearchFilter()
        } else {
            setBigRegion()
            filtersManager.add(filter: .name(searchText))
        }
    }
    
    func updateClubs(_ clubs: [FullClubData]) {
        self.clubs = clubs.sorted(by: { [weak self] data1, data2 in
            guard let location = self?.locationManager.location else { return true }
            let distance1 =  CLLocation(latitude: data1.addressData.latitude, longitude: data1.addressData.longitude).distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
            let distance2 =  CLLocation(latitude: data2.addressData.latitude, longitude: data2.addressData.longitude).distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
            return distance1 < distance2
        })
        updateMapClubs(by: self.clubs)
        updateClubListCards(by: self.clubs)
    }
    
    func updateMapClubs(by clubs: [FullClubData]) {
        mapClubs = clubs.getMapClubData()
    }
    
    func updateClubListCards(by clubs: [FullClubData]) {
        clubListCards = clubs.getListCardData()
    }
    
    func addClubs(_ clubs: [FullClubData]) {
        self.clubs.append(contentsOf: clubs)
        addMapClubs(by: clubs)
        addClubListCards(by: clubs)
    }
    
    func addMapClubs(by clubs: [FullClubData]) {
        mapClubs.append(contentsOf: clubs.getMapClubData())
    }
    
    func addClubListCards(by clubs: [FullClubData]) {
        clubListCards.append(contentsOf: clubs.getListCardData())
    }
    
    func getClubDetails(by clubID: String) -> ClubDetailsData? {
        let club = clubs.first { $0.id == clubID }?.getDetailsData()
        return club
    }
}
