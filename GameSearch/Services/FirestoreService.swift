//
//  FirestoreService.swift
//  GameSearch
//
//  Created by Ацамаз on 14.05.2025.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift


protocol NetworkServiceProtocol {
    func fetchClubs(filter: ClubsFilter?) -> AnyPublisher<[FullClubData], any Error>
}

extension NetworkServiceProtocol {
    func fetchClubs() -> AnyPublisher<[FullClubData], any Error> {
        fetchClubs(filter: nil)
    }
}


final class FirestoreService: NetworkServiceProtocol {
    private let db = Firestore.firestore()
    private let mapper: DataMapperProtocol = DataMapper()
    
    func fetchClubs(filter: ClubsFilter?) -> AnyPublisher<[FullClubData], any Error> {
        getClubsPublisher(filter: filter)
            .map({ collectionSnapshot in
                collectionSnapshot.documents
                    .compactMap { [weak self] docSnapshot in
                        guard let self else {
                            print("FirestoreService выгрузился из памяти")
                            return nil
                        }
                        return self.mapper.mapToFullClubData(id: docSnapshot.documentID, docSnapshot.data())
                    }
            })
            .eraseToAnyPublisher()
    }
}

private extension FirestoreService {
    func getClubsPublisher(filter: ClubsFilter?, startFrom: Int = 0, limit: Int = 15) -> Future<QuerySnapshot, any Error> {
        switch filter {
        case .name(let name):
            return db.collection("clubs")
                .whereField("nameLowercase", isGreaterThanOrEqualTo: name.lowercased())
                .whereField("nameLowercase", isLessThan: name.lowercased() + "\u{f8ff}")
                .limit(to: 15)
                .getDocuments()
        case nil:
            return db.collection("clubs")
                .limit(to: limit)
                .getDocuments()
        }
    }
}
