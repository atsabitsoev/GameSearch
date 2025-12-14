//
//  GalleryViewModel.swift
//  GameSearch
//
//  Created by Ацамаз on 15.12.2025.
//

import Foundation


final class GalleryViewModel: ObservableObject {
    @Published var aspectRatio: CGFloat = 16/9
    @Published var fullImageSheet: Bool = false
    @Published var imageTapped: URL? = nil {
        didSet {
            fullImageSheet = true
        }
    }

    private var pendingAspectRatio: CGFloat = 1
    private var aspectRatioWasSet = false


    func saveAspectRatio(_ aspectRatio: CGFloat) {
        if !aspectRatioWasSet {
            pendingAspectRatio = aspectRatio
            aspectRatioWasSet = true
        }
    }

    func updateAspectRatio() {
        aspectRatio = pendingAspectRatio
    }
}
