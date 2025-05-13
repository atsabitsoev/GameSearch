//
//  MapListModels.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//


enum MapListButtonState {
    case map
    case list
    
    var buttonData: MapListButtonData {
        switch self {
        case .map: return MapListButtonData(title: "Список", systemImage: "list.bullet")
        case .list: return MapListButtonData(title: "Карта", systemImage: "map")
        }
    }
    
    
    mutating func toggle() {
        switch self {
        case .map:
            self = .list
        case .list:
            self = .map
        }
    }
    
    var isMap: Bool {
        self == .map
    }
    
    var isList: Bool {
        self == .list
    }
}

struct MapListButtonData {
    let title: String
    let systemImage: String
}
