//
//  ClubDetailsViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 20.05.2025.
//

import Combine
import Foundation


final class ClubDetailsViewModel: ClubDetailsViewModelProtocol {
    private let interactor: ClubDetailsInteractorProtocol
    private let clubDetails: ClubDetailsData
    
    @Published var sectionPickerState: DetailsSection = .common
    @Published var output: ClubDetailsVMOutput?


    init(data: ClubDetailsData, interactor: ClubDetailsInteractorProtocol) {
        self.clubDetails = data
        self.interactor = interactor
        
        setupOutput()
    }
}

private extension ClubDetailsViewModel {
    func setupOutput() {
        let priceInfo = makePriceInfoData()
        let info = makeInfoData()
        let locationInfo = makeLocationInfoData()

        output = .init(
            priceInfo: priceInfo,
            info: info,
            locationInfo: locationInfo,
            images: clubDetails.images,
            phone: clubDetails.phoneNumber,
            name: clubDetails.name,
            rating: clubDetails.ratingString,
            logo: clubDetails.logo
        )
    }
    
    func makePriceInfoData() -> PriceInfoData? {
        guard !clubDetails.rooms.isEmpty else { return nil }
        
        let roomsData = clubDetails.rooms.map { rooms in
            switch rooms {
            case let .pc(room):
                return RoomUniversalData(
                    id: room.id,
                    roomName: room.roomName,
                    minPriceForHour: room.minPriceForHour,
                    maxPriceForHour: room.maxPriceForHour
                )
            case let .playstation(room):
                return RoomUniversalData(
                    id: room.id,
                    roomName: room.roomName,
                    minPriceForHour: room.minPriceForHour,
                    maxPriceForHour: room.maxPriceForHour
                )
            }
        }
        
        return PriceInfoData(
            headerText: Constants.priceInfoHeader,
            roomsData: roomsData,
            buttonText: Constants.priceInfoButton
        )
    }
    
    func makeInfoData() -> InfoData? {
        guard !clubDetails.description.isEmpty else { return nil }
        
        return InfoData(
            title: Constants.infoTitle,
            desc: clubDetails.description
        )
    }

    func makeLocationInfoData() -> LocationInfoData {
        clubDetails.addressData
    }
}


private enum Constants {
    
    static let priceInfoHeader = "Стоимость"
    static let priceInfoButton = "Открыть прайс"
    
    
    static let infoTitle = "Описание"
}
