//
//  GameSearchApp.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import SwiftUI
import CoreLocation
import Firebase

@main
struct GameSearchApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ClubListView(viewModel: ClubListViewModel(interactor: ClubListInteractor()))
                .preferredColorScheme(.dark)
        }
    }
}
