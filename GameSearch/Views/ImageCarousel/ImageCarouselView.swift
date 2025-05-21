//
//  ImageCarouselView.swift
//  GameSearch
//
//  Created by Ацамаз on 21.05.2025.
//

import SwiftUI

struct ImageCarouselView: View {
    let images: [String]

    var body: some View {
        GeometryReader { geometry in
            TabView {
                ForEach(images, id: \.self) { imageURL in
                    ZStack {
                        Color.gray.opacity(0.1)

                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            case .failure:
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.red)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .ignoresSafeArea()
                    }
                    .ignoresSafeArea()
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

