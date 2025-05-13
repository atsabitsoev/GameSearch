//
//  TabBarModifier.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import SwiftUI

struct TabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
    }
}

extension View {
    func setupTabBarAppearance() -> some View {
        self
            .modifier(TabBarModifier())
    }
}
