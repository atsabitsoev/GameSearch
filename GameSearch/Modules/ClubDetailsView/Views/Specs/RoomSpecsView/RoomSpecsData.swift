//
//  RoomSpecsData.swift
//  GameSearch
//
//  Created by Ацамаз on 06.06.2025.
//

import Foundation

struct RoomSpecsData: Identifiable, Hashable {
    let id = UUID()
    let roomName: String
    let stationCount: Int
    let videocard: String
    let chip: String
    let mouse: String
    let keyboard: String
    let headphones: String
    let ram: Int
    let monitorBrand: String
    let monitorDiag: Int
    let hz: Int
}
