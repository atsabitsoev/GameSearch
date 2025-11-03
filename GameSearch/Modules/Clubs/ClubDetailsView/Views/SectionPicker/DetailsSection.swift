//
//  DetailsSection.swift
//  GameSearch
//
//  Created by Ацамаз on 22.05.2025.
//

enum DetailsSection: Int, Hashable, Identifiable {
    case common
    case specification


    var title: String {
        switch self {
        case .common:
            return "Информация"
        case .specification:
            return "Характеристики"
        }
    }

    var id: Int { rawValue }
}
