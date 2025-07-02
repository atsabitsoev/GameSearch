//
//  PaginatedResult.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 01.07.2025.
//

import FirebaseFirestore


struct PaginatedResult<T> {
    let items: [T]
    let paginationState: PaginationState
}

// MARK: - Pagination Models
struct PaginationState {
    let lastDocument: DocumentSnapshot?
    let hasMoreData: Bool
    
    static let initial = PaginationState(lastDocument: nil, hasMoreData: true)
}
