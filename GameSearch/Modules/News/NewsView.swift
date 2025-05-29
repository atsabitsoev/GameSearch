//
//  NewsView.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 29.05.2025.
//

import SwiftUI

struct NewsView: View {
    @State private var moveRight = false
    @State private var isJumping = false
    @State private var glow = false

    var body: some View {
        NavigationView {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(EAColor.background, for: .navigationBar)
                .toolbarVisibility(.visible, for: .navigationBar)
                .toolbarVisibility(.visible, for: .tabBar)
                .toolbarBackground(EAColor.background, for: .tabBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Новости")
                            .font(EAFont.navigationBarTitle)
                            .foregroundStyle(EAColor.textPrimary)
                    }
                }
        }
    }
    var contentView: some View {
        VStack(spacing: 24) {
            GhostHeader()
            ghostNewsList
            Spacer()
        }
        .background(EAColor.background)
    }

    private var ghostNewsList: some View {
        VStack(spacing: 16) {
            ForEach(0..<2) { _ in
                GhostNewsCell()
            }
        }
    }
}

#Preview {
    NewsView()
}
