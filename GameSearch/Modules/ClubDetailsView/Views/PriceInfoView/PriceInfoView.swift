//
//  PriceInfoView.swift
//  GameSearch
//
//  Created by Ацамаз on 29.05.2025.
//

import SwiftUI


struct PriceInfoView: View {
    private let priceInfo: PriceInfoData


    init(_ priceInfo: PriceInfoData) {
        self.priceInfo = priceInfo
    }


    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                headerView
                pricesView
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
        Text(priceInfo.headerText)
            .font(.headline)
            .foregroundStyle(EAColor.info2)
    }

    var pricesView: some View {
        Group {
            ForEach(priceInfo.roomsData) { room in
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
    }

    var showFullPriceButton: some View {
        Button {
            print("hello")
        } label: {
            HStack {
                Spacer()
                Text(priceInfo.buttonText)
                    .foregroundStyle(EAColor.textPrimary)
                    .font(EAFont.infoBold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(EAColor.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Spacer()
            }
        }
        .padding(.top, 12)
    }
}

