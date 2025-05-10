//
//  GameSearchApp.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import SwiftUI
import CoreLocation

@main
struct GameSearchApp: App {
    var body: some Scene {
        WindowGroup {
            ClubListView(viewModel: ClubListViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
