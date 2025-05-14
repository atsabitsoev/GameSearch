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
    @Published var clubs: [Club] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init(interactor: Interactor) {
        self.interactor = interactor
        subscribeSearchText()
    }
    
    
    func onViewAppear() {
        fetchClubs()
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
    
    func updateClubs(_ clubs: [Club]) {
        self.clubs = clubs
    }
}
