//
//  PriceImageSheet.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 06.06.2025.
//

import SwiftUI


struct PriceImageSheet: View {
    let imageURL: URL?

    var body: some View {
        VStack {
            Spacer()

            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    progressView
                case .success(let image):
                    VStack {
                        titleView
                        successImage(image)
                    }
                case .failure:
                    errorImage
                @unknown default:
                    EmptyView()
                }
            }

            Spacer()
        }
        .ignoresSafeArea()
    }
}

private extension PriceImageSheet {
    func successImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            .cornerRadius(20)
            .padding(16)
            .transition(.scale.combined(with: .opacity))

    }

    var titleView: some View {
        Text(Constants.title)
            .font(EAFont.title)
            .foregroundStyle(EAColor.textPrimary)
    }

    var progressView: some View {
        HStack {
            Spacer()
            ProgressView() {
                Text(Constants.proggressLabel)
            }
            .scaleEffect(1.5)
            Spacer()
        }
    }

    var errorImage: some View {
        VStack {
            Text(Constants.errorLabel)
            Image(systemName: "xmark.octagon")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)
                .padding()
        }
    }

    enum Constants {
        static let title = "Все тарифы"
        static let proggressLabel = "Загружаем"
        static let errorLabel = "Не удалось загрузить тарифы"
    }
}
