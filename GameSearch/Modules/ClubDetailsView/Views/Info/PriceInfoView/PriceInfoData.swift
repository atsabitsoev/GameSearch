//
//  PriceInfoData.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 29.05.2025.
//

import Foundation


struct PriceInfoData {
    let headerText: String
    let roomsData: [RoomUniversalData]
    let buttonText: String
}

struct RoomUniversalData: Identifiable {
    let id: UUID
    let roomName: String
    let minPriceForHour: Int
    let maxPriceForHour: Int
}
