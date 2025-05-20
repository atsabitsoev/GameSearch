//
//  ClubDetailsView.swift
//  GameSearch
//
//  Created by Ацамаз on 20.05.2025.
//

import SwiftUI


struct ClubDetailsView: View {
    @ObservedObject var viewModel: ClubDetailsViewModel
    
    var body: some View {
        Text("Club Details")
            .font(.largeTitle)
            .padding()
    }
}
