//
//  MapClubData.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 14.05.2025.
//

import CoreLocation

struct MapClubData {
    init(club: FullClubData) {
        self.name = club.name
        self.location = .init(latitude: club.addressData.latitude, longitude: club.addressData.longitude)
    }
    var location: CLLocationCoordinate2D
    var name: String
}

extension FullClubData {
    func getMapClubData() -> MapClubData {
        MapClubData(club: self)
    }
}

extension Array where Element == FullClubData {
    func getMapClubData() -> [MapClubData] {
        self.map{ $0.getMapClubData() }
    }
}
