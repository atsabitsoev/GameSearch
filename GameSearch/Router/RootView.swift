//
//  RootView.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI


struct RootView<Factory: ScreenFactoryProtocol>: View {
    @EnvironmentObject private var router: Router
    private let factory: Factory
    
    
    init(factory: Factory) {
        self.factory = factory
    }
    

    var body: some View {
        TabView {
            Tab("Клубы", systemImage: "cube") {
                NavigationStack(path: $router.path) {
                    factory.makeClubListView()
                        .environmentObject(router)
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .details(let data):
                                factory.makeClubDetailsView(data)
                            }
                        }
                        .enableSwipeBack()
                }
                .setupClubsNavigationBarAppearance()
            }
            Tab("Новости", systemImage: "newspaper") {
                NavigationStack(path: $router.path) {
                    factory.makeNewsListView()
                }
            }
        }
        .tint(EAColor.accent)
        .setupTabBarAppearance()
    }
}
