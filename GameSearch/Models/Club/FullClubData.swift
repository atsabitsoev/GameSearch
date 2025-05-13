//
//  FullClubData.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import Foundation

struct Club {
    let name: String
}


extension Club {
    static let mock: [Club] = [
        Club(name: "Cyber Arena"),
        Club(name: "Ultra Game"),
        Club(name: "Gaming Gladiator"),
        Club(name: "Force"),
        Club(name: "Space"),
        Club(name: "Rage"),
        Club(name: "Rampage"),
        Club(name: "Shoot"),
        Club(name: "AltPC"),
        Club(name: "WarGame")
    ]
}

struct FullClubData {
    let id: Int
    let name: String
    let description: String
    let image: String
    let rating: Double
    let configuration: ClubConfiguration
    let prices: String
    let promos: String
    let comments: [String]
    let additionalInfo: String
    let subscribers: Int
}

struct ClubConfiguration {
    let mouse: String
    let keyboard: String
    let monitor: String
    let videocard: String
    let hz: String
    let games: [ClubGame]
}

struct ClubGame {
    let name: String
}

extension FullClubData {
    static let mock: [FullClubData] = [
        FullClubData(
            id: 1,
            name: "CyberZone",
            description: "Современный киберклуб с топовым железом.",
            image: "cyberzone.jpg",
            rating: 4.8,
            configuration: ClubConfiguration(
                mouse: "Logitech G Pro",
                keyboard: "SteelSeries Apex Pro",
                monitor: "ASUS ROG Swift PG259QN",
                videocard: "NVIDIA RTX 4090",
                hz: "360Hz",
                games: [
                    ClubGame(name: "CS2"),
                    ClubGame(name: "Valorant"),
                    ClubGame(name: "Dota 2")
                ]
            ),
            prices: "от 150 ₽/час",
            promos: "10% скидка в будни до 15:00",
            comments: ["Лучшее место!", "Очень комфортно и мощно."],
            additionalInfo: "Открыто 24/7, бесплатный Wi-Fi",
            subscribers: 1200
        ),
        FullClubData(
            id: 2,
            name: "GameHouse",
            description: "Идеальное место для геймеров всех возрастов.",
            image: "gamehouse.png",
            rating: 4.5,
            configuration: ClubConfiguration(
                mouse: "Razer DeathAdder",
                keyboard: "HyperX Alloy",
                monitor: "Acer Predator XB273",
                videocard: "NVIDIA RTX 3080",
                hz: "240Hz",
                games: [
                    ClubGame(name: "Fortnite"),
                    ClubGame(name: "Overwatch 2")
                ]
            ),
            prices: "от 120 ₽/час",
            promos: "Каждый 5-й час бесплатно",
            comments: ["Уютная атмосфера.", "Персонал дружелюбный."],
            additionalInfo: "Есть зона отдыха и кафе",
            subscribers: 850
        ),
        FullClubData(
            id: 3,
            name: "Arena Play",
            description: "Площадка для настоящих киберспортсменов.",
            image: "arena_play.jpg",
            rating: 4.9,
            configuration: ClubConfiguration(
                mouse: "Zowie EC2",
                keyboard: "Corsair K95",
                monitor: "BenQ Zowie XL2546",
                videocard: "NVIDIA RTX 4080",
                hz: "240Hz",
                games: [
                    ClubGame(name: "PUBG"),
                    ClubGame(name: "Apex Legends")
                ]
            ),
            prices: "от 200 ₽/час",
            promos: "Счастливые часы с 12:00 до 16:00",
            comments: ["Много места и крутая техника."],
            additionalInfo: "Проводятся турниры каждую субботу",
            subscribers: 2300
        ),
        FullClubData(
            id: 4,
            name: "Pixel Point",
            description: "Уютный клуб в центре города.",
            image: "pixelpoint.png",
            rating: 4.2,
            configuration: ClubConfiguration(
                mouse: "Glorious Model O",
                keyboard: "Razer Huntsman",
                monitor: "MSI Optix MAG",
                videocard: "NVIDIA RTX 3070",
                hz: "165Hz",
                games: [
                    ClubGame(name: "Minecraft"),
                    ClubGame(name: "GTA V")
                ]
            ),
            prices: "от 100 ₽/час",
            promos: "1 час в подарок при первом визите",
            comments: ["Хорошо для вечернего отдыха."],
            additionalInfo: "Работает до полуночи",
            subscribers: 600
        ),
        FullClubData(
            id: 5,
            name: "NextLevel",
            description: "Следующий уровень игрового опыта.",
            image: "nextlevel.jpg",
            rating: 4.7,
            configuration: ClubConfiguration(
                mouse: "Razer Viper Ultimate",
                keyboard: "Logitech G915",
                monitor: "LG UltraGear",
                videocard: "NVIDIA RTX 4060 Ti",
                hz: "144Hz",
                games: [
                    ClubGame(name: "League of Legends"),
                    ClubGame(name: "Warzone")
                ]
            ),
            prices: "от 130 ₽/час",
            promos: "3 часа — по цене 2-х",
            comments: ["Крутая атмосфера и звук."],
            additionalInfo: "Поддержка VR, гарнитуры включены",
            subscribers: 950
        )
    ]
}
