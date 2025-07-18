//
//  MapClubData.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 14.05.2025.
//

import CoreLocation

struct MapClubData {
    init(club: FullClubData) {
        self.id = club.id
        self.name = club.name
        self.location = .init(latitude: club.addressData.latitude, longitude: club.addressData.longitude)
        self.logo = URL(string: club.logo)
        self.address = club.addressData.address.simplifiedAddress()
        self.rating = String(club.rating)
        self.image = URL(string: club.images.first ?? "")
        self.price = club.configurations.getMinPrice()
        self.phone = club.phoneNumber
    }
    let id: String
    let location: CLLocationCoordinate2D
    let name: String
    let logo: URL?
    let address: String?
    let rating: String?
    let image: URL?
    let price: Int
    let phone: String?
}

extension MapClubData: Equatable {
    static func == (lhs: MapClubData, rhs: MapClubData) -> Bool {
        lhs.id == rhs.id
    }
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
