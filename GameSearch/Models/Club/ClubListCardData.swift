//
//  ClubListCardData.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

struct ClubListCardData {
    init(club: FullClubData) {
        self.id = club.id
        self.name = club.name
        self.rating = club.rating
        self.ratingString = String(format: "%.1f", club.rating)
        self.price = "от \(club.configurations.getMinPrice()) ₽/час"
    }
    
    var id: Int
    var name: String
    var rating: Double
    var ratingString: String
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


fileprivate extension Array where Element == RoomConfiguration {
    func getMinPrice() -> Int {
        compactMap({ configuration in
            switch configuration {
            case .pc(let pCConfiguration):
                return pCConfiguration.minPriceForHour
            case .playstation:
                return nil
            }
        })
        .min() ?? 0
    }
}
