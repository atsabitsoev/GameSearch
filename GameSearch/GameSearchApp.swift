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
    @State private var showMainView = false
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if showMainView {
                RootView(factory: ScreenFactory())
                    .environmentObject(ClubsRouter())
                    .environmentObject(ArticlesRouter())
                    .preferredColorScheme(.dark)
            } else {
                LaunchView(showMainView: $showMainView)
            }
        }
    }
}
