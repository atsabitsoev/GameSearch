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
        return Future<[FullClubData], Error> { promise in
            ClubParserService.parse(
                clubLinks: [
                    URL(string: "https://langame.ru/799451573_computerniy_club_altpc_moskva_zelenograd")!,
                    URL(string: "https://langame.ru/799449913_computerniy_club_true-gamers-zelenograd_moskva_zelenograd")!,
                    URL(string: "https://langame.ru/799451215_computerniy_club_colizeum-zelenograd_moskva_zelenograd")!,
                    URL(string: "https://langame.ru/682344255_computerniy_club_cyber-arena-storm-v-k1640_moskva_zelenograd")!,
                    URL(string: "https://langame.ru/799449748_computerniy_club_black-zelenograd_moskva_zelenograd")!,
                    URL(string: "https://langame.ru/799452588_computerniy_club_kiber-kub_moskva_zelenograd")!,
                    URL(string: "https://langame.ru/799450982_computerniy_club_cyberx-zelenograd-317_moskva_zelenograd")!,
                    URL(string: "https://langame.ru/799450215_computerniy_club_cyberx-zelenograd-georgievskii_moskva_zelenograd")!,
                    URL(string: "https://langame.ru/799449380_computerniy_club_black-star-gaming-zelenograd_moskva_zelenograd")!
                ]
            ) { result in
                promise(.success(result))
            }
        }
                .eraseToAnyPublisher()
//        getClubsPublisher(filter: filter)
//            .map({ collectionSnapshot in
//                collectionSnapshot.documents
//                    .compactMap { [weak self] docSnapshot in
//                        guard let self else {
//                            print("FirestoreService выгрузился из памяти")
//                            return nil
//                        }
//                        return self.mapper.mapToFullClubData(id: docSnapshot.documentID, docSnapshot.data())
//                    }
//            })
//            .eraseToAnyPublisher()
    }
}

private extension FirestoreService {
    func getClubsPublisher(filter: ClubsFilter?) -> Future<QuerySnapshot, any Error> {
        switch filter {
        case .name(let name):
            return db.collection("clubs")
                .whereField("nameLowercase", isGreaterThanOrEqualTo: name.lowercased())
                .whereField("nameLowercase", isLessThan: name.lowercased() + "\u{f8ff}")
                .getDocuments()
        case nil:
            return db.collection("clubs").getDocuments()
        }
    }
}
