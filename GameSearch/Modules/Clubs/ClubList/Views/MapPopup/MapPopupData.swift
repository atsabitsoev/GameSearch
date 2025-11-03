//
//  MapPopupData.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 15.06.2025.
//

struct MapPopupData: Equatable {
    var selectedClub: MapClubData
    var state: MapPopupState
}

enum MapPopupState {
    case full
    case min
}
