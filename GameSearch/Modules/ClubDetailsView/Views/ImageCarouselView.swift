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
                                proggressView(geometry)
                            case .success(let image):
                                successImage(image, geometry)
                            case .failure:
                                errorView()
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

private extension ImageCarouselView {
    func successImage(_ image: Image, _ geo: GeometryProxy) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
    }
    
    func proggressView(_ geo: GeometryProxy) -> some View {
        ProgressView()
            .frame(width: geo.size.width, height: geo.size.height)
    }
    
    func errorView() -> some View {
        VStack(alignment: .center) {
            Spacer()
            errorImage
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    var errorImage: some View {
        Image(systemName: "xmark.octagon")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundColor(.gray)
            .padding()
    }
}

