//
//  ClubListCardData.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

struct ClubListCardData {
    init(club: FullClubData) {
        self.id = club.id
        self.videocard = club.configuration.videocard
        self.name = club.name
        self.rating = club.rating
        self.ratingString = String(format: "%.1f", club.rating)
        self.price = club.prices
    }
    
    var id: Int
    var name: String
    var rating: Double
    var ratingString: String
    var videocard: String
    var price: String
}


extension FullClubData {
    func getListCardData() -> ClubListCardData {
        ClubListCardData(club: self)
    }
}

extension Array where Element == FullClubData {
    func getListCardData() -> [ClubListCardData] {
        self.map{ $0.getListCardData() }
    }
}
