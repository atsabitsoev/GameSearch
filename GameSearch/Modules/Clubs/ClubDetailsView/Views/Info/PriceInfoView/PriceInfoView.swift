//
//  PriceInfoView.swift
//  GameSearch
//
//  Created by Ацамаз on 29.05.2025.
//

import SwiftUI


struct PriceInfoView: View {
    @State private var showSheet = false

    private let priceInfo: PriceInfoData


    init(_ priceInfo: PriceInfoData) {
        self.priceInfo = priceInfo
    }


    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                headerView
                commonPriceView
                allPricesButton
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(EAColor.info1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .fullScreenCover(isPresented: $showSheet) {
            priceImage
        }
    }
}


private extension PriceInfoView {
    var headerView: some View {
        Text(priceInfo.headerText)
            .font(.headline)
            .foregroundStyle(EAColor.info2)
    }
    
    var commonPriceView: some View {
        // Берём minPriceForHour с любой комнаты тк сейчас у всех комнат одинаковое значение
        let minPriceForHour = priceInfo.roomsData.first?.minPriceForHour ?? 0
        
        return HStack {
            Text("Все тарифы")
                .font(.body)
                .bold()
                .foregroundStyle(EAColor.textPrimary)
            Spacer()
            Group {
                Text("от ")
                + Text("\(minPriceForHour)").bold()
                    .fontWidth(.expanded)
                + Text(" ₽/час")
            }
            .font(.body)
            .foregroundStyle(EAColor.textPrimary)
        }
    }

    @ViewBuilder
    var allPricesButton: some View {
        if let _ = priceInfo.priceImage {
            Button {
                showSheet.toggle()
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

    var priceImage: some View {
        PriceImageSheet(imageURL: priceInfo.priceImage, shouldHideTitle: false)
            .presentationBackground(EAColor.background)
    }
}

