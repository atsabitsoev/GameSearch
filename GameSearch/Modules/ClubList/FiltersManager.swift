//
//  FiltersManager.swift
//  GameSearch
//
//  Created by Ацамаз on 28.07.2025.
//

import Combine

final class FiltersManager: ObservableObject {
    @Published var filters: [ClubsFilter] = []
    // Не учитывается фильтр поиска, поиск для пользователя отдельная фича
    @Published var filtersApplied: Bool = false
    
    
    func add(filter: ClubsFilter) {
        defer { checkStatus() }
        filters.append(filter)
    }
    
    // Заменяет все фильтры кроме фильтра поиска по названию
    func remakeFilters(_ newFilters: [ClubsFilter]) {
        defer { checkStatus() }
        if let searchFilter = filters.first(where: { filter in
            if case .name = filter {
                return true
            } else {
                return false
            }
        }) {
            var result = newFilters
            result.append(searchFilter)
            filters = result
        } else {
            filters = newFilters
        }
    }
    
    func removeSearchFilter() {
        defer { checkStatus() }
        filters.removeAll { filter in
            if case .name = filter {
                return true
            } else {
                return false
            }
        }
    }
    
    func removeAll() {
        defer { checkStatus() }
        filters = []
    }
}

private extension FiltersManager {
    func checkStatus() {
        if filters.contains(where: { filter in
            if case .name = filter {
                return true
            } else {
                return false
            }
        }) {
            filtersApplied = filters.count - 1 > 0
        } else {
            filtersApplied = filters.count > 0
        }
    }
}
