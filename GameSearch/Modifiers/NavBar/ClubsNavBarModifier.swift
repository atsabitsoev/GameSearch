//
//  ClubsNavBarModifier.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import SwiftUI

struct ClubsNavBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                let backButtonAppearance = UIBarButtonItemAppearance()
                backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
                appearance.backButtonAppearance = backButtonAppearance
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
    }
}

extension View {
    func setupClubsNavigationBarAppearance() -> some View {
        self
            .modifier(ClubsNavBarModifier())
    }
}
