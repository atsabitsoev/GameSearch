//
//  ClubListCardData.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

struct ClubListCardData {
    init(club: FullClubData) {
        self.id = club.id
        self.image = club.image
        self.name = club.name
        self.rating = club.rating
    }
    
    var id: Int
    var name: String
    var rating: Double
    var image: String
}


extension FullClubData {
    func getListCardData() -> ClubListCardData {
        ClubListCardData(club: self)
    }
}

extension Array where Element == FullClubData {
    func getListCardData() -> [ClubListCardData] {
        self.map({ ClubListCardData(club: $0) })
    }
}
