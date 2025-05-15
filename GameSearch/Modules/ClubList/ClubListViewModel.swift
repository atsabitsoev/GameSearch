//
//  ClubListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Foundation
import Combine

enum Destination {
    case details(_ club: ClubDetailsData)
}

final class ClubListViewModel<Interactor: ClubListInteractorProtocol>: ClubListViewModelProtocol {
    private let interactor: Interactor
    
    @Published var searchText = ""
    @Published private var clubs: [FullClubData] = []
    @Published var mapClubs: [MapClubData] = []
    @Published var clubListCards: [ClubListCardData] = []
    @Published var destination: Destination?
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init(interactor: Interactor) {
        self.interactor = interactor
        subscribeSearchText()
    }
    
    
    func onViewAppear() {
        fetchClubs()
    }
    
    func routeToDetails(clubID: Int) {
        guard let club = getClubDetails(by: clubID) else {
            print("Club not found, need delete from Base")
            return
        }
        destination = .details(club)
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
    
    func fetchClubs(filter: ClubsFilter? = nil) {
        interactor.fetchClubs(filter: filter)
            .receive(on: RunLoop.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { clubs in
                self.updateClubs(clubs)
            }
            .store(in: &cancellables)
    }
    
    func searchTextChanged(_ searchText: String) {
        fetchClubs(filter: searchText.isEmpty ? nil : .name(searchText))
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
    
    func getClubDetails(by clubID: Int) -> ClubDetailsData? {
        let club = clubs.first { $0.id == clubID }?.getDetailsData()
        return club
    }
}
