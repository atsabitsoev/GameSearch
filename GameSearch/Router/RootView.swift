//
//  RootView.swift
//  GameSearch
//
//  Created by Ацамаз on 16.05.2025.
//

import SwiftUI


struct RootView<Factory: ScreenFactoryProtocol>: View {
    @EnvironmentObject private var clubsRouter: ClubsRouter
    @EnvironmentObject private var articlesRouter: ArticlesRouter
    private let factory: Factory
    
    
    init(factory: Factory) {
        self.factory = factory
    }
    

    var body: some View {
        TabView {
            Tab("Новости", systemImage: "newspaper") {
                NavigationStack(path: $articlesRouter.path) {
                    factory.makeArticlesListView()
                }
            }
            Tab("Клубы", systemImage: "cube") {
                NavigationStack(path: $clubsRouter.path) {
                    factory.makeClubListView()
                        .environmentObject(clubsRouter)
                        .navigationDestination(for: ClubsRoute.self) { route in
                            switch route {
                            case .details(let data):
                                factory.makeClubDetailsView(data)
                            }
                        }
                        .enableSwipeBack()
                }
                .setupClubsNavigationBarAppearance()
            }
        }
        .tint(EAColor.accent)
        .setupTabBarAppearance()
    }
}
