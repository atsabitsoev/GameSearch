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
        self.image = club.image
        self.prices = club.prices
        self.promos = club.promos
        self.additionalInfo = club.additionalInfo
    }
    
    let id: Int
    let name: String
    let rating: Double
    let ratingString: String
    let description: String
    let image: String
    let prices: String
    let promos: String
    let additionalInfo: String
}


extension FullClubData {
    func getDetailsData() -> ClubDetailsData {
        ClubDetailsData(club: self)
    }
}
