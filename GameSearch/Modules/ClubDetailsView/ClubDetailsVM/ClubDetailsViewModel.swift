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
    @Published var selectedSpecId: UUID?


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
        let specsData = makeSpecsData()

        output = .init(
            priceInfo: priceInfo,
            info: info,
            locationInfo: locationInfo,
            specsData: specsData,
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

    func makeSpecsData() -> [RoomSpecsData] {
        let data = clubDetails.rooms.compactMap { room in
            switch room {
            case let .pc(pcRoom):
                return RoomSpecsData(
                    roomName: pcRoom.roomName,
                    stationCount: pcRoom.stationCount,
                    videocard: pcRoom.videoCard,
                    chip: pcRoom.chip,
                    mouse: pcRoom.mouse,
                    keyboard: pcRoom.keyboard,
                    headphones: pcRoom.headphones,
                    ram: pcRoom.ram,
                    monitorBrand: pcRoom.monitor,
                    monitorDiag: pcRoom.monitorDiag,
                    hz: pcRoom.hz
                )
            default:
                return nil
            }
        }
        selectedSpecId = data.last?.id
        return data
    }
}


private enum Constants {
    
    static let priceInfoHeader = "Стоимость"
    static let priceInfoButton = "Все тарифы"

    
    static let infoTitle = "Описание"
}
