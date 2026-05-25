//
//  GameSearchApp.swift
//  GameSearch
//
//  Created by Ацамаз on 09.05.2025.
//

import SwiftUI
import CoreLocation
import Firebase
import AnalyticsModule

@main
struct GameSearchApp: App {
    init() {
        FirebaseApp.configure()
        AppMetricaReporter.activate()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(factory: ScreenFactory())
                .environmentObject(ClubsRouter())
                .environmentObject(ArticlesRouter())
                .environmentObject(TournamentsRouter())
                .preferredColorScheme(.dark)
        }
    }
}
