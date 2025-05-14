//
//  ClubListInteractor.swift
//  GameSearch
//
//  Created by Ацамаз on 13.05.2025.
//

import Foundation
import Combine

final class ClubListInteractor: ClubListInteractorProtocol {
    private let service: NetworkServiceProtocol = FirestoreService()
    
    
    func fetchClubs(filter: ClubsFilter?) -> AnyPublisher<[FullClubData], any Error> {
        service.fetchClubs(filter: filter).eraseToAnyPublisher()
    }
}
