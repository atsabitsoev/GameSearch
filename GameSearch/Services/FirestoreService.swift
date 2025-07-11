//
//  FirestoreService.swift
//  GameSearch
//
//  Created by Ацамаз on 14.05.2025.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import CoreLocation


// MARK: - Updated Protocol
protocol NetworkServiceProtocol {
    func fetchClubs(filter: ClubsFilter?, radius: QueryRadiusData) -> AnyPublisher<[FullClubData], any Error>
}

// MARK: - Updated Service
final class FirestoreService: NetworkServiceProtocol {
    private let db = Firestore.firestore()
    private let mapper: DataMapperProtocol = DataMapper()
    private let pageSize: Int = 15
    
    func fetchClubs(filter: ClubsFilter?, radius: QueryRadiusData) -> AnyPublisher<[FullClubData], any Error> {
        getClubsPublisher(filter: filter, radius: radius)
            .map({ [weak self] collectionSnapshot in
                guard let self = self else {
                    print("FirestoreService выгрузился из памяти")
                    return []
                }
                
                let clubs = collectionSnapshot.documents
                    .compactMap { docSnapshot in
                        self.mapper.mapToFullClubData(id: docSnapshot.documentID, docSnapshot.data())
                    }
                
                return clubs
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Private Extensions
private extension FirestoreService {
    func getClubsPublisher(filter: ClubsFilter?, radius: QueryRadiusData) -> Future<QuerySnapshot, any Error> {
        var baseQuery = buildBaseQuery()
        if let filter, case let ClubsFilter.name(name) = filter {
            baseQuery = applySearch(to: baseQuery, name: name)
            baseQuery = applyRadius(to: baseQuery, radius: radius)
        } else {
            baseQuery = applyRadius(to: baseQuery, radius: radius)
        }
        
        return baseQuery.getDocuments()
    }
    
    func buildBaseQuery() -> Query {
        db.collection("clubs")
            .limit(to: 150)
    }
    
    func applySearch(to query: Query, name: String) -> Query {
        query
            .whereField("nameLowercase", isGreaterThanOrEqualTo: name.lowercased())
            .whereField("nameLowercase", isLessThan: name.lowercased() + "\u{f8ff}")
            .order(by: "nameLowercase")
    }
    
    func applyRadius(to query: Query, radius: QueryRadiusData) -> Query {
        query
            .whereField("addressData.latitude", isGreaterThan: radius.center.latitude - radius.delta.latitude / 2)
            .whereField("addressData.latitude", isLessThan: radius.center.latitude + radius.delta.latitude / 2)
            .whereField("addressData.longitude", isGreaterThan: radius.center.longitude - radius.delta.longitude / 2)
            .whereField("addressData.longitude", isLessThan: radius.center.longitude + radius.delta.longitude / 2)
    }
}


struct QueryRadiusData: Equatable {
    let center: CLLocationCoordinate2D
    let delta: CLLocationCoordinate2D
}
