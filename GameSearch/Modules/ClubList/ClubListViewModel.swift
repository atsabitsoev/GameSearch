//
//  ClubListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Foundation

final class ClubListViewModel: ClubListViewModelProtocol {
    @Published var clubs: [Club] = Club.mock
    
    private var currentTask: Task<(), any Error>?
    
    
    func searchTextChanged(_ searchText: String) {
        currentTask?.cancel()
        
        guard !searchText.isEmpty else {
            clubs = Club.mock
            return
        }
        
        currentTask = Task {
            do {
                try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                await updateClubs(Club.mock.filter({ club in
                    club.name.contains(searchText)
                }))
            }
        }
    }
}


private extension ClubListViewModel {
    @MainActor
    func updateClubs(_ clubs: [Club]) {
        self.clubs = clubs
    }
}
