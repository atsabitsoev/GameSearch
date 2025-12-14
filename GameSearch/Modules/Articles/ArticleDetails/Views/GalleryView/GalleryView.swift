//
//  GalleryView.swift
//  GameSearch
//
//  Created by Ацамаз on 15.12.2025.
//

import SwiftUI

struct GalleryView: View {
    let images: [String]

    @StateObject var viewModel: GalleryViewModel = .init()


    var body: some View {
            TabView {
                ForEach(images, id: \.self) { imageUrl in
                    ZStack {
                        Color.gray.opacity(0.1)

                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                proggressView()
                            case .success(let image):
                                successImage(image)
                                    .onAppear {
                                        viewModel.updateAspectRatio()
                                    }
                                    .onTapGesture {
                                        viewModel.imageTapped = URL(string: imageUrl)
                                    }
                            case .failure:
                                errorView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .aspectRatio(viewModel.aspectRatio, contentMode: .fit)
            .tabViewStyle(PageTabViewStyle())
            .cornersRadius(16)
            .fullScreenCover(isPresented: $viewModel.fullImageSheet) {
                if let url = viewModel.imageTapped {
                    PriceImageSheet(imageURL: url, shouldHideTitle: true)
                        .presentationBackground(EAColor.background)
                }
            }
    }
}

private extension GalleryView {
    func successImage(_ image: Image) -> some View {
        if let uiImage = image.asUIImage() {
            let aspectRatio = uiImage.size.width / uiImage.size.height
            viewModel.saveAspectRatio(aspectRatio)
        }
        return image
            .resizable()
            .scaledToFit()
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
}


private extension Image {
    @MainActor func asUIImage() -> UIImage? {
        ImageRenderer(content: self).uiImage
    }
}

