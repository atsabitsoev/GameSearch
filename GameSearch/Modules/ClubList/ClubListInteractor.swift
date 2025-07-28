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
    
    func fetchClubs(filters: [ClubsFilter], radius: QueryRadiusData) -> AnyPublisher<[FullClubData], any Error> {
        service.fetchClubs(filters: filters, radius: radius)
    }
}
