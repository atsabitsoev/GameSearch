//
//  ClubDetailsData.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

struct ClubDetailsData {
    init(club: FullClubData) {
        self.id = club.id
        self.name = club.name
        self.rating = club.rating
        self.ratingString = String(format: "%.1f", club.rating)
        self.description = club.description
        self.images = club.images
        self.prices = "цена тут"
        self.additionalInfo = club.additionalInfo
        self.phoneNumber = club.phoneNumber
        self.rooms = club.configurations
        self.logo = club.logo
        self.addressData = LocationInfoData(address: club.addressData.address, long: club.addressData.longitude, lat: club.addressData.latitude)
    }
    
    let id: String
    let name: String
    let rating: Double
    let ratingString: String
    let description: String
    let images: [String]
    let prices: String
    let additionalInfo: String
    let phoneNumber: Int?
    let rooms: [RoomConfiguration]
    let logo: String
    let addressData: LocationInfoData
}


extension FullClubData {
    func getDetailsData() -> ClubDetailsData {
        ClubDetailsData(club: self)
    }
}
