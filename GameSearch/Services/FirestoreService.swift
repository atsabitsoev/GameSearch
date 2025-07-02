//
//  FirestoreService.swift
//  GameSearch
//
//  Created by Ацамаз on 14.05.2025.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift


// MARK: - Updated Protocol
protocol NetworkServiceProtocol {
    func fetchClubs(filter: ClubsFilter?, paginationState: PaginationState) -> AnyPublisher<PaginatedResult<FullClubData>, any Error>
    func fetchFirstPageClubs(filter: ClubsFilter?) -> AnyPublisher<PaginatedResult<FullClubData>, any Error>
    func fetchNextPageClubs(filter: ClubsFilter?, paginationState: PaginationState) -> AnyPublisher<PaginatedResult<FullClubData>, any Error>
}

extension NetworkServiceProtocol {
    func fetchFirstPageClubs(filter: ClubsFilter?) -> AnyPublisher<PaginatedResult<FullClubData>, any Error> {
        fetchClubs(filter: filter, paginationState: .initial)
    }
    
    func fetchNextPageClubs(filter: ClubsFilter?, paginationState: PaginationState) -> AnyPublisher<PaginatedResult<FullClubData>, any Error> {
        fetchClubs(filter: filter, paginationState: paginationState)
    }
}

// MARK: - Updated Service
final class FirestoreService: NetworkServiceProtocol {
    private let db = Firestore.firestore()
    private let mapper: DataMapperProtocol = DataMapper()
    private let pageSize: Int = 15
    
    func fetchClubs(filter: ClubsFilter?, paginationState: PaginationState) -> AnyPublisher<PaginatedResult<FullClubData>, any Error> {
        getClubsPublisher(filter: filter, paginationState: paginationState)
            .map({ [weak self] collectionSnapshot in
                guard let self = self else {
                    print("FirestoreService выгрузился из памяти")
                    return PaginatedResult(items: [], paginationState: PaginationState(lastDocument: nil, hasMoreData: false))
                }
                
                let clubs = collectionSnapshot.documents
                    .compactMap { docSnapshot in
                        self.mapper.mapToFullClubData(id: docSnapshot.documentID, docSnapshot.data())
                    }
                
                // Определяем, есть ли еще данные
                let hasMoreData = collectionSnapshot.documents.count == self.pageSize
                let lastDocument = collectionSnapshot.documents.last
                
                let newPaginationState = PaginationState(
                    lastDocument: lastDocument,
                    hasMoreData: hasMoreData
                )
                
                return PaginatedResult(items: clubs, paginationState: newPaginationState)
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Private Extensions
private extension FirestoreService {
    func getClubsPublisher(filter: ClubsFilter?, paginationState: PaginationState) -> Future<QuerySnapshot, any Error> {
        let baseQuery = buildBaseQuery(filter: filter)
        let paginatedQuery = applyPagination(to: baseQuery, paginationState: paginationState)
        
        return paginatedQuery.getDocuments()
    }
    
    func buildBaseQuery(filter: ClubsFilter?) -> Query {
        switch filter {
        case .name(let name):
            return db.collection("clubs")
                .whereField("nameLowercase", isGreaterThanOrEqualTo: name.lowercased())
                .whereField("nameLowercase", isLessThan: name.lowercased() + "\u{f8ff}")
                .order(by: "nameLowercase") // Важно для пагинации с фильтрами
        case nil:
            return db.collection("clubs")
                .order(by: FieldPath.documentID()) // Сортировка по ID для стабильной пагинации
        }
    }
    
    func applyPagination(to query: Query, paginationState: PaginationState) -> Query {
        var paginatedQuery = query.limit(to: pageSize)
        
        if let lastDocument = paginationState.lastDocument {
            paginatedQuery = paginatedQuery.start(afterDocument: lastDocument)
        }
        
        return paginatedQuery
    }
}
