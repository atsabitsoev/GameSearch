//
//  DictToFullClubDataMapper.swift
//  GameSearch
//
//  Created by Ацамаз on 14.05.2025.
//

import Foundation

protocol DataMapperProtocol {
    func mapToFullClubData(_ dict: [String: Any]) -> FullClubData
}


final class DataMapper: DataMapperProtocol {
    func mapToFullClubData(_ dict: [String: Any]) -> FullClubData {
        let id = dict["id"] as? Int ?? 0
        let name = dict["name"] as? String ?? ""
        let description = dict["description"] as? String ?? ""
        let image = dict["image"] as? String ?? ""
        let rating = dict["rating"] as? Double ?? 0.0
        let prices = dict["prices"] as? String ?? ""
        let promos = dict["promos"] as? String ?? ""
        let comments = dict["comments"] as? [String] ?? []
        let additionalInfo = dict["additionalInfo"] as? String ?? ""
        let subscribers = dict["subscribers"] as? Int ?? 0

        // Address data
        let addressDict = dict["addressData"] as? [String: Any] ?? [:]
        let address = addressDict["address"] as? String ?? ""
        let latitude = addressDict["latitude"] as? Double ?? 0.0
        let longitude = addressDict["longitude"] as? Double ?? 0.0
        let addressData = ClubAddressData(
            address: address,
            latitude: latitude,
            longitude: longitude
        )

        // Configuration data
        let configDict = dict["configuration"] as? [String: Any] ?? [:]
        let mouse = configDict["mouse"] as? String ?? ""
        let keyboard = configDict["keyboard"] as? String ?? ""
        let monitor = configDict["monitor"] as? String ?? ""
        let videocard = configDict["videocard"] as? String ?? ""
        let hz = configDict["hz"] as? String ?? ""

        let gamesArray = configDict["games"] as? [[String: Any]] ?? []
        let games: [ClubGame] = gamesArray.compactMap { gameDict in
            guard let name = gameDict["name"] as? String else { return nil }
            return ClubGame(name: name)
        }

        let configuration = ClubConfiguration(
            mouse: mouse,
            keyboard: keyboard,
            monitor: monitor,
            videocard: videocard,
            hz: hz,
            games: games
        )

        return FullClubData(
            id: id,
            name: name,
            description: description,
            image: image,
            rating: rating,
            configuration: configuration,
            prices: prices,
            promos: promos,
            comments: comments,
            additionalInfo: additionalInfo,
            subscribers: subscribers,
            addressData: addressData
        )
    }
}
