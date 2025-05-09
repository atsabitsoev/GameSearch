//
//  ClubListViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Foundation

final class ClubListViewModel: ClubListViewModelProtocol {
    @Published var clubs: [Club] = Club.mock
    
    
    func userDidRefresh() async {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        await updateClubs()
    }
    
    
    @MainActor
    private func updateClubs() {
        if self.clubs.count > 1 {
            self.clubs = [Club(name: "Писька")]
        } else {
            self.clubs = Club.mock
        }
    }
}
