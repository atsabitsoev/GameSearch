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
    
    
    func fetchFirstPageClubs(filter: ClubsFilter?) -> AnyPublisher<PaginatedResult<FullClubData>, any Error> {
        service.fetchFirstPageClubs(filter: filter)
    }
    
    func fetchNextPageClubs(filter: ClubsFilter?, paginationState: PaginationState) -> AnyPublisher<PaginatedResult<FullClubData>, any Error> {
        service.fetchNextPageClubs(filter: filter, paginationState: paginationState)
    }
}
