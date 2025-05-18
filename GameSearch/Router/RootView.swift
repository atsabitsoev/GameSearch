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
        NavigationStack(path: $router.path) {
            factory.makeClubListView()
                .environmentObject(router)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .details(let data):
                        Text(data.name)
                    }
                }
        }
        .toolbarVisibility(.visible, for: .tabBar)
        .toolbarBackground(Color(white: 0.1), for: .tabBar)
        .setupNavigationBarAppearance()
    }
}
