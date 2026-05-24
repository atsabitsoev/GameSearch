//
//  ClubListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Foundation
import Combine
import CoreLocation
import AnalyticsModule

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
    @Published var cameraRegion: CameraRegion
    @Published var mapListButtonState: MapListButtonState = .list
    @Published var geoApplied: Bool = true

    @Published var showFiltersView: Bool = false

    private var shouldHideGeoButton = true
    private var lastSearchedText: String = ""
    private var cancellables = Set<AnyCancellable>()

    /// Единственный «в полёте» запрос на клубы. Каждая новая загрузка
    /// отменяет предыдущую — это убирает мигание `isLoading` и
    /// гонки при быстрых изменениях фильтров/региона.
    private var loadCancellable: AnyCancellable?

    init(interactor: Interactor) {
        self.interactor = interactor
        let radius = Self.defaultRadius(for: nil)
        self.cameraRegion = CameraRegion(center: radius.center, delta: radius.delta)
    }


    func onViewAppear() {
        subscribeSearchText()
        subscribeFiltersAdjustRegion()
        subscribeLoadTriggers()
        subscribeLocationAuth()
        locationManager.onLocationGot = { [weak self] in
            self?.handleLocationGot()
        }
        locationManager.onLocationChange = { [weak self] in
            self?.handleLocationChange()
        }
        // Первая загрузка — сразу, без 700 мс debounce-задержки пайплайна.
        loadClubsNow()
    }

    func onFiltersApply(_ filters: [ClubsFilter]) {
        filtersManager.remakeFilters(filters)
    }

    func routeToDetails(clubID: String, router: ClubsRouter) {
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
        shouldHideGeoButton = true
        loadWithDefaultDelta()
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

    /// Меняет камеру при изменении фильтров. САМ запрос не дёргает —
    /// загрузка идёт через единый `subscribeLoadTriggers`.
    func subscribeFiltersAdjustRegion() {
        filtersManager.$filters
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] filters in
                guard let self else { return }
                guard self.mapListButtonState == .list else { return }
                if filters.isEmpty {
                    self.setDefaultRegion()
                } else {
                    self.setMediumRegion()
                }
            }
            .store(in: &cancellables)
    }

    /// ЕДИНСТВЕННЫЙ путь к загрузке: пара (фильтры, регион). Любое
    /// существенное изменение любой стороны → debounce 700 мс → запрос.
    /// `removeDuplicates` с эпсилоном по региону защищает от шума MapKit
    /// и микро-апдейтов локации.
    func subscribeLoadTriggers() {
        Publishers.CombineLatest(
            filtersManager.$filters,
            $cameraRegion
        )
        .dropFirst() // первая загрузка — явно из onViewAppear
        .removeDuplicates { lhs, rhs in
            lhs.0 == rhs.0 && lhs.1.isApproximatelyEqual(to: rhs.1)
        }
        .debounce(for: .milliseconds(700), scheduler: DispatchQueue.main)
        .sink { [weak self] _, _ in
            self?.checkGeoButton()
            self?.loadClubsNow()
        }
        .store(in: &cancellables)
    }

    func checkGeoButton() {
        if shouldHideGeoButton {
            geoApplied = true
        } else {
            let current = CameraRegion(center: cameraRegion.center, delta: cameraRegion.delta)
            let defaultRegion = Self.defaultRegion(for: locationManager.location)
            geoApplied = current.isApproximatelyEqual(to: defaultRegion)
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

    /// Первое получение координат — центрируем карту, только если юзер
    /// сам её ещё не двигал (geoApplied всё ещё true).
    func handleLocationGot() {
        guard geoApplied else { return }
        loadWithDefaultDelta()
    }

    /// На каждый последующий апдейт координат данные не дёргаем —
    /// просто помечаем, что юзер «съехал» относительно дефолтного региона,
    /// чтобы показать кнопку «вернуться к моему положению».
    func handleLocationChange() {
        geoApplied = false
    }

    func loadWithDefaultDelta() {
        shouldHideGeoButton = true
        setDefaultRegion()
    }

    func setDefaultRegion() {
        cameraRegion = Self.defaultRegion(for: locationManager.location)
    }

    func setMediumRegion() {
        cameraRegion = CameraRegion(center: cameraRegion.center, delta: CLLocationCoordinate2D(latitude: 0.2, longitude: 0.2))
    }

    func setBigRegion() {
        cameraRegion = CameraRegion(center: cameraRegion.center, delta: CLLocationCoordinate2D(latitude: 3, longitude: 3))
    }

    static func defaultRegion(for location: CLLocationCoordinate2D?) -> CameraRegion {
        let radius = defaultRadius(for: location)
        return CameraRegion(center: radius.center, delta: radius.delta)
    }

    static func defaultRadius(for location: CLLocationCoordinate2D?) -> QueryRadiusData {
        let center = location ?? CLLocationCoordinate2D(latitude: 55.7482, longitude: 37.6210)
        return QueryRadiusData(
            center: center,
            delta: CLLocationCoordinate2D(latitude: 0.04, longitude: 0.04)
        )
    }

    func loadClubsNow() {
        let filters = filtersManager.filters
        let radius = QueryRadiusData(center: cameraRegion.center, delta: cameraRegion.delta)
        isLoading = true
        loadCancellable = interactor.fetchClubs(filters: filters, radius: radius)
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


// MARK: - Analytics

extension ClubListViewModel {
    func sendMapListButtonTap(for state: MapListButtonState) {
        AppMetricaReporter.reportEvent(
            "clubs_view_mode",
            parameters: ["mode": state == .map ? "map" : "list"]
        )
    }
}
