//
//  DictToFullClubDataMapper.swift
//  GameSearch
//
//  Created by Ацамаз on 14.05.2025.
//

import Foundation
import FirebaseFirestore

protocol DataMapperProtocol {
    func mapToFullClubData(id: String, _ dict: [String: Any]) -> FullClubData
}


final class DataMapper: DataMapperProtocol {
    func mapToFullClubData(id: String, _ dict: [String: Any]) -> FullClubData {
        FullClubData(id: id, dictionary: dict)
    }
}


fileprivate extension FullClubData {
    init(id: String, dictionary: [String: Any]) {
        let additionalInfo = dictionary["additionalInfo"] as? String ?? ""
        let addressDict = dictionary["addressData"] as? [String: Any] ?? [:]
        let commentsArray = dictionary["comments"] as? [[String: Any]] ?? []
        let configsArray = dictionary["configurations"] as? [[String: Any]] ?? []
        let description = dictionary["description"] as? String ?? ""
        let images = dictionary["images"] as? [String] ?? []
        let name = dictionary["name"] as? String ?? ""
        let nameLowercase = dictionary["nameLowercase"] as? String ?? ""
        let rating = dictionary["rating"] as? Double ?? 0
        let subscribers = dictionary["subscribers"] as? Int ?? 0
        let tags = dictionary["tags"] as? [String] ?? []
        let logo = dictionary["logo"] as? String ?? ""
        let phoneNumber = dictionary["phoneNumber"] as? String
        let allPricesImage = dictionary["allPricesImage"] as? String

        self.additionalInfo = additionalInfo
        self.description = description
        self.id = id
        self.images = images
        self.name = name
        self.nameLowercase = nameLowercase
        self.rating = rating
        self.subscribers = subscribers

        self.addressData = AddressData(dictionary: addressDict)
        self.comments = commentsArray.compactMap { Comment(dictionary: $0) }
        self.configurations = configsArray.compactMap { RoomConfiguration(dictionary: $0) }
        self.tags = tags
        self.logo = logo
        self.phoneNumber = phoneNumber
        self.allPricesImage = URL(string: allPricesImage ?? "")
    }
}


fileprivate extension AddressData {
    init(dictionary: [String: Any]) {
        self.address = dictionary["address"] as? String ?? ""
        self.latitude = dictionary["latitude"] as? Double ?? 0
        self.longitude = dictionary["longitude"] as? Double ?? 0
    }
}

fileprivate extension RoomConfiguration {
    init?(dictionary: [String: Any]) {
        guard let type = dictionary["type"] as? String else { return nil }

        switch type {
        case "pc":
            if let pc = PCConfiguration(dictionary: dictionary) {
                self = .pc(pc)
            } else {
                return nil
            }
        case "playstation":
            if let console = ConsoleConfiguration(dictionary: dictionary) {
                self = .playstation(console)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

fileprivate extension Comment {
    init?(dictionary: [String: Any]) {
        guard
            let authorName = dictionary["authorName"] as? String,
            let likesCount = dictionary["likesCount"] as? Int,
            let rate = dictionary["rate"] as? Double,
            let text = dictionary["text"] as? String
        else { return nil }

        self.authorName = authorName
        self.likesCount = likesCount
        self.rate = rate
        self.text = text
    }
}

fileprivate extension PCConfiguration {
    init?(dictionary: [String: Any]) {
        guard
            let chip = dictionary["chip"] as? String,
            let games = dictionary["games"] as? [String],
            let headphones = dictionary["headphones"] as? String,
            let hz = dictionary["hz"] as? Int,
            let keyboard = dictionary["keyboard"] as? String,
            let maxPriceForHour = dictionary["maxPriceForHour"] as? Int,
            let minPriceForHour = dictionary["minPriceForHour"] as? Int,
            let monitor = dictionary["monitor"] as? String,
            let monitorDiag = dictionary["monitorDiag"] as? Int,
            let mouse = dictionary["mouse"] as? String,
            let ram = dictionary["ram"] as? String,
            let roomName = dictionary["roomName"] as? String,
            let stationCount = dictionary["stationCount"] as? Int,
            let type = dictionary["type"] as? String,
            let videoCard = dictionary["videocard"] as? String
        else { return nil }

        self.chip = chip
        self.games = games
        self.headphones = headphones
        self.hz = hz
        self.keyboard = keyboard
        self.maxPriceForHour = maxPriceForHour
        self.minPriceForHour = minPriceForHour
        self.monitor = monitor
        self.monitorDiag = monitorDiag
        self.mouse = mouse
        self.ram = ram
        self.roomName = roomName
        self.stationCount = stationCount
        self.type = type
        self.videoCard = videoCard
    }
}

fileprivate extension ConsoleConfiguration {
    init?(dictionary: [String: Any]) {
        guard
            let games = dictionary["games"] as? [String],
            let maxPriceForHour = dictionary["maxPriceForHour"] as? Int,
            let minPriceForHour = dictionary["minPriceForHour"] as? Int,
            let roomName = dictionary["roomName"] as? String,
            let tvDiag = dictionary["tvDiag"] as? Int,
            let type = dictionary["type"] as? String
        else { return nil }

        self.games = games
        self.maxPriceForHour = maxPriceForHour
        self.minPriceForHour = minPriceForHour
        self.roomName = roomName
        self.tvDiag = tvDiag
        self.type = type
    }
}
