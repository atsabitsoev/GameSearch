//
//  FullClubDataToDictionary.swift
//  GameSearch
//
//  Created by Ацамаз on 02.07.2025.
//

import FirebaseFirestore

// MARK: - Преобразование FullClubData в словарь
extension FullClubData {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "additionalInfo": additionalInfo,
            "addressData": addressData.toDictionary(),
            "comments": comments.map { $0.toDictionary() },
            "configurations": configurations.map { $0.toDictionary() },
            "description": description,
            "images": images,
            "name": name,
            "nameLowercase": nameLowercase,
            "rating": rating,
            "subscribers": subscribers,
            "tags": tags,
            "logo": logo,
            "bestVideocardRate": configurations.last?.bestVideocardRate() ?? -1
        ]
        
        // Опциональные поля
        if let phoneNumber = phoneNumber {
            dict["phoneNumber"] = phoneNumber
        }
        if let allPricesImage = allPricesImage?.absoluteString {
            dict["allPricesImage"] = allPricesImage
        }
        
        return dict
    }
}

private extension RoomConfiguration {
    func bestVideocardRate() -> Int {
        switch self {
        case .pc(let pCConfiguration):
            if pCConfiguration.videoCard.hasPrefix("NVIDIA GeForce RTX 20") {
                return 2
            } else if pCConfiguration.videoCard.hasPrefix("NVIDIA GeForce RTX 30") {
                return 3
            } else if pCConfiguration.videoCard.hasPrefix("NVIDIA GeForce RTX 40") {
                return 4
            } else if pCConfiguration.videoCard.hasPrefix("NVIDIA GeForce RTX 50") {
                return 5
            } else {
                return -1
            }
        case .playstation:
            return -1
        }
    }
}

// MARK: - Преобразование AddressData в словарь
extension AddressData {
    func toDictionary() -> [String: Any] {
        return [
            "address": address,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}

// MARK: - Преобразование Comment в словарь
extension Comment {
    func toDictionary() -> [String: Any] {
        return [
            "authorName": authorName,
            "likesCount": likesCount,
            "rate": rate,
            "text": text
        ]
    }
}

// MARK: - Преобразование RoomConfiguration в словарь
extension RoomConfiguration {
    func toDictionary() -> [String: Any] {
        switch self {
        case .pc(let pcConfig):
            return pcConfig.toDictionary().merging(["type": "pc"]) { (current, _) in current }
        case .playstation(let consoleConfig):
            return consoleConfig.toDictionary().merging(["type": "playstation"]) { (current, _) in current }
        }
    }
}

// MARK: - Преобразование PCConfiguration в словарь
extension PCConfiguration {
    func toDictionary() -> [String: Any] {
        return [
            "chip": chip,
            "games": games,
            "headphones": headphones,
            "hz": hz,
            "keyboard": keyboard,
            "maxPriceForHour": maxPriceForHour,
            "minPriceForHour": minPriceForHour,
            "monitor": monitor,
            "monitorDiag": monitorDiag,
            "mouse": mouse,
            "ram": ram,
            "roomName": roomName,
            "stationCount": stationCount,
            "type": type,
            "videocard": videoCard
        ]
    }
}

// MARK: - Преобразование ConsoleConfiguration в словарь
extension ConsoleConfiguration {
    func toDictionary() -> [String: Any] {
        return [
            "games": games,
            "maxPriceForHour": maxPriceForHour,
            "minPriceForHour": minPriceForHour,
            "roomName": roomName,
            "tvDiag": tvDiag,
            "type": type
        ]
    }
}
