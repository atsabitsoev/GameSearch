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
            ghostHeader
            ghostNewsList
            Spacer()
        }
        .background(EAColor.background)
    }

    private var ghostHeader: some View {
        VStack(spacing: 12) {
            AnimatedGhostView()

            Text("Новости скоро будут!")
                .font(EAFont.title)
                .foregroundStyle(EAColor.textPrimary)

            Text("Заходите позже, чтобы узнать последние обновления и сплетни в мире игр")
                .font(.subheadline)
                .foregroundColor(EAColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 16)
    }

    private var ghostNewsList: some View {
        VStack(spacing: 16) {
            ForEach(0..<2) { _ in
                ghostNewsCell
            }
        }
    }

    private var ghostNewsCell: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(EAColor.info2)
                .frame(height: 120)
                .overlay(
                    VStack {
                        Spacer()
                        Image(systemName: "newspaper")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(EAColor.textPrimary)
                        Spacer()
                    }
                )

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(EAColor.textPrimary.opacity(0.2))
                    .frame(width: 200, height: 12)

                RoundedRectangle(cornerRadius: 4)
                    .fill(EAColor.textPrimary.opacity(0.15))
                    .frame(width: 260, height: 10)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 220, height: 10)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
        .background(EAColor.info1)
        .cornerRadius(12)
        .shadow(color: EAColor.secondaryBackground, radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NewsView()
}

struct AnimatedGhostView: View {
    var body: some View {
        Image("ghost")
            .resizable()
            .frame(width: 64, height: 64)
            .foregroundColor(EAColor.infoMain)
    }
}
