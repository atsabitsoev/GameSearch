//
//  PriceInfoView.swift
//  GameSearch
//
//  Created by Ацамаз on 29.05.2025.
//

import SwiftUI


struct PriceInfoView: View {
    private let rooms: [RoomConfiguration.UniversalData]


    init(rooms: [RoomConfiguration]) {
        self.rooms = rooms.map(\.universalData)
    }


    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                headerView
                Spacer()
                    .frame(height: 4)
                pricesView
                Spacer()
                    .frame(height: 8)
                showFullPriceButton

            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(EAColor.info1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


private extension PriceInfoView {
    var headerView: some View {
        HStack {
            Text("Стоимость")
                .font(.headline)
                .foregroundStyle(EAColor.info2)
        }
    }

    var pricesView: some View {
        ForEach(rooms) { room in
            HStack {
                Text(room.roomName)
                    .font(.body)
                    .bold()
                    .foregroundStyle(EAColor.textPrimary)
                Spacer()
                Group {
                    Text("от ")
                    + Text("\(room.minPriceForHour)").bold()
                        .fontWidth(.expanded)
                    + Text(" ₽/час")
                }
                .font(.body)
                .foregroundStyle(EAColor.textPrimary)
            }
        }
    }

    var showFullPriceButton: some View {
        Button {
            print("hello")
        } label: {
            HStack {
                Spacer()
                Text("Открыть прайс")
                    .foregroundStyle(EAColor.textPrimary)
                    .font(EAFont.infoBold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(EAColor.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Spacer()
            }
        }
    }
}


private extension RoomConfiguration {
    struct UniversalData: Identifiable {
        let id: UUID
        let roomName: String
        let minPriceForHour: Int
        let maxPriceForHour: Int
    }

    var universalData: UniversalData {
        switch self {
        case let .pc(room): return UniversalData(
            id: room.id,
            roomName: room.roomName,
            minPriceForHour: room.minPriceForHour,
            maxPriceForHour: room.maxPriceForHour
        )
        case let .playstation(room): return UniversalData(
            id: room.id,
            roomName: room.roomName,
            minPriceForHour: room.minPriceForHour,
            maxPriceForHour: room.maxPriceForHour
        )
        }
    }
}

