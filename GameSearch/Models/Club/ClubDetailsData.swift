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
        self.description = club.description
        self.image = club.image
        self.prices = club.prices
        self.promos = club.promos
        self.additionalInfo = club.additionalInfo
    }
    
    var id: Int
    var name: String
    var rating: Double
    var description: String
    var image: String
    var prices: String
    var promos: String
    var additionalInfo: String
}


extension FullClubData {
    func getDetailsData() -> ClubDetailsData {
        ClubDetailsData(club: self)
    }
}

extension ClubDetailsData: Hashable {
    static func == (lhs: ClubDetailsData, rhs: ClubDetailsData) -> Bool {
        lhs.id == rhs.id
    }
}
