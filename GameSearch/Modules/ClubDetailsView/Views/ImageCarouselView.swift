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
            TabView {
                ForEach(images, id: \.self) { imageURL in
                    ZStack {
                        Color.gray.opacity(0.1)

                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .empty:
                                proggressView()
                            case .success(let image):
                                successImage(image)
                            case .failure:
                                errorView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .ignoresSafeArea()
                    }
                    .offset(y: -getKeyWindow().safeAreaInsets.top)
                    .ignoresSafeArea()
                }
            }
            .tabViewStyle(PageTabViewStyle())
    }
}

private extension ImageCarouselView {
    func successImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFill()
            .clipped()
    }
    
    func proggressView() -> some View {
        ProgressView()
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
    
    
    func getKeyWindow() -> UIWindow {
        UIApplication
        .shared
        .connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .first { $0.isKeyWindow }!
    }
}

