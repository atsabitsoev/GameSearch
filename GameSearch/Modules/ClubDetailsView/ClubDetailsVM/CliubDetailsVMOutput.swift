//
//  CliubDetailsVMOutput.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 29.05.2025.
//


struct ClubDetailsVMOutput {
    let priceInfo: PriceInfoData?
    let info: InfoData?
    let locationInfo: LocationInfoData
    let specsData: [RoomSpecsData]
    let images: [String]
    let phone: Int?
    let name: String
    let rating: String
    let logo: String?
}
