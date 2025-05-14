//
//  ClubListInteractor.swift
//  GameSearch
//
//  Created by Ацамаз on 13.05.2025.
//

import Foundation
import Combine

final class ClubListInteractor: ClubListInteractorProtocol {
    func fetchClubs(filter: ClubsFilter?) -> AnyPublisher<[FullClubData], any Error> {
        return Just(FullClubData.mock)
            .map({ clubs in
                guard let filter else { return clubs }
                switch filter {
                case .name(let name):
                    return clubs.filter({ $0.name.contains(name) })
                }
            })
            .setFailureType(to: Error.self)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
