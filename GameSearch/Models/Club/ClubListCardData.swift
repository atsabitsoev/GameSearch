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
        self.price = "\(club.configurations.getMinPrice())"
        self.addressString = club.addressData.address.simplifiedAddress()
        self.tags = club.tags
        self.logo = club.logo
    }
    
    let id: String
    let name: String
    let rating: Double
    let ratingString: String
    let price: String
    let addressString: String
    let tags: [String]
    let logo: String
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
