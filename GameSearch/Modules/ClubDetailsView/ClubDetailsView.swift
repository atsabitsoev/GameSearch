//
//  ClubDetailsView.swift
//  GameSearch
//
//  Created by Ацамаз on 20.05.2025.
//

import SwiftUI


struct ClubDetailsView<ViewModel: ClubDetailsViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel


    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }


    var body: some View {
        Text("Club Details")
            .font(.largeTitle)
            .padding()
    }
}
