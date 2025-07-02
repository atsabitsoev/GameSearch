//
//  ClubListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Foundation
import Combine

final class ClubListViewModel<Interactor: ClubListInteractorProtocol>: ClubListViewModelProtocol {
    private let interactor: Interactor
    
    @Published var searchText = ""
    @Published private var clubs: [FullClubData] = []
    @Published var mapClubs: [MapClubData] = []
    @Published var clubListCards: [ClubListCardData] = []
    @Published var mapPopupClub: MapPopupData?
    @Published var isLoading = false
    @Published var hasMoreData = true
    
    private var lastSearchedText: String = ""
    private var currentPaginationState = PaginationState.initial
    private var cancellables = Set<AnyCancellable>()
    
    
    init(interactor: Interactor) {
        self.interactor = interactor
        subscribeSearchText()
    }
    
    
    func onViewAppear() {
        loadFirstPage()
    }
    
    func onScrollToEnd(with cardID: String) {
        if cardID == clubListCards.last?.id {
            loadNextPage()
        }
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
}


private extension ClubListViewModel {
    func subscribeSearchText() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.searchTextChanged(text)
            }
            .store(in: &cancellables)
    }
    
    func loadFirstPage(filter: ClubsFilter? = nil) {
        isLoading = true
        
        interactor.fetchFirstPageClubs(filter: filter)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] result in
                    self?.updateClubs(result.items)
                    self?.currentPaginationState = result.paginationState
                    self?.hasMoreData = result.paginationState.hasMoreData
                }
            )
            .store(in: &cancellables)
    }
    
    // Загрузка следующей страницы
    func loadNextPage() {
        guard hasMoreData && !isLoading else { return }

        isLoading = true
        
        interactor.fetchNextPageClubs(filter: searchText.isEmpty ? nil : .name(searchText), paginationState: currentPaginationState)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] result in
                    self?.addClubs(result.items)
                    self?.currentPaginationState = result.paginationState
                    self?.hasMoreData = result.paginationState.hasMoreData
                }
            )
            .store(in: &cancellables)
    }
    
    func searchTextChanged(_ searchText: String) {
        guard lastSearchedText != searchText else { return }
        lastSearchedText = searchText
        loadFirstPage(filter: searchText.isEmpty ? nil : .name(searchText))
    }
    
    func updateClubs(_ clubs: [FullClubData]) {
        self.clubs = clubs
        updateMapClubs(by: clubs)
        updateClubListCards(by: clubs)
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
