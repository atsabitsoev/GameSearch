//
//  FullClubData.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Foundation
import FirebaseFirestore


struct FullClubData {
    let additionalInfo: String
    let addressData: AddressData
    let comments: [Comment]
    let configurations: [RoomConfiguration]
    let description: String
    let id: String
    let images: [String]
    let name: String
    let nameLowercase: String
    let rating: Double
    let subscribers: Int
    let tags: [String]
    let logo: String
}

struct AddressData {
    let address: String
    let longitude: Double
    let latitude: Double
}

struct Comment {
    let authorName: String
    let likesCount: Int
    let rate: Double
    let text: String
}

enum RoomConfiguration {
    case pc(PCConfiguration)
    case playstation(ConsoleConfiguration)
}

struct PCConfiguration {
    let chip: String
    let games: [String]
    let headphones: String
    let hz: Int
    let keyboard: String
    let maxPriceForHour: Int
    let minPriceForHour: Int
    let monitor: String
    let monitorDiag: Int
    let mouse: String
    let ram: Int
    let roomName: String
    let stationCount: Int
    let type: String
    let videoCard: String
}

struct ConsoleConfiguration {
    let games: [String]
    let maxPriceForHour: Int
    let minPriceForHour: Int
    let roomName: String
    let tvDiag: Int
    let type: String
}


extension FullClubData {
    static let mock: [FullClubData] = [
        FullClubData(
            additionalInfo: "Тренировки и командные игры",
            addressData: AddressData(
                address: "ул. Тверская, д. 20",
                longitude: 37,
                latitude: 55
            ),
            comments: [
                Comment(
                    authorName: "Геймер1",
                    likesCount: 10,
                    rate: 4.5,
                    text: "Отличный клуб, играю в доту"
                )
            ],
            configurations: [
                .pc(
                    PCConfiguration(
                        chip: "Intel Core i5 12400F",
                        games: ["Dota 2", "CS2", "PUBG"],
                        headphones: "HyperX Cloud II",
                        hz: 144,
                        keyboard: "SteelSeries Apex",
                        maxPriceForHour: 200,
                        minPriceForHour: 100,
                        monitor: "AOC 27G2",
                        monitorDiag: 27,
                        mouse: "Logitech G Pro",
                        ram: 32,
                        roomName: "Standard",
                        stationCount: 10,
                        type: "pc",
                        videoCard: "RTX 3070"
                    )
                )
            ],
            description: "Лучший киберспорт центр Москвы",
            id: "1",
            images: ["https://example.com/image1.jpg"],
            name: "Кибер-Арена",
            nameLowercase: "кибер-арена",
            rating: 4.8,
            subscribers: 1500,
            tags: ["VIP-zone", "VR", "Турниры", "Напитки", "Кондиционер"],
            logo: "https://www.beboss.pro/listings/fr/3397/frPcVGLu.jpg"
        ),

        FullClubData(
            additionalInfo: "PlayStation 5 + турниры",
            addressData: AddressData(
                address: "пр. Ленина, д. 1",
                longitude: 30,
                latitude: 59
            ),
            comments: [
                Comment(
                    authorName: "Фанат FIFA",
                    likesCount: 5,
                    rate: 4.0,
                    text: "Хорошее место для друзей и FIFA"
                )
            ],
            configurations: [
                .playstation(
                    ConsoleConfiguration(
                        games: ["FIFA 23", "Mortal Kombat"],
                        maxPriceForHour: 160,
                        minPriceForHour: 100,
                        roomName: "PlayZone",
                        tvDiag: 48,
                        type: "playstation"
                    )
                )
            ],
            description: "Консольный клуб с турнирами",
            id: "2",
            images: ["https://example.com/image2.jpg"],
            name: "PS Lounge",
            nameLowercase: "ps lounge",
            rating: 4.3,
            subscribers: 900,
            tags: ["VIP-zone", "VR", "Турниры", "Напитки", "Кондиционер"],
            logo: "https://www.beboss.pro/listings/fr/3397/frPcVGLu.jpg"
        )
    ]
}
