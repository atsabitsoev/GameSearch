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
    
    private let screenFactory = ScreenFactory()
    
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            screenFactory.makeClubListView()
                .preferredColorScheme(.dark)
        }
    }
}
