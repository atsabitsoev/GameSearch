//
//  EmptyListView.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 10.07.2025.
//

import SwiftUI


struct EmptyListView: View {
    let title: String
    let subtitle: String
    let isLoading: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text(title)
                .font(EAFont.title)
                .foregroundStyle(EAColor.textPrimary)
                .padding(.bottom, 4)
            Text(subtitle)
                .font(EAFont.info)
                .foregroundStyle(EAColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            emptyImage
            Spacer()
        }
    }
    
    @ViewBuilder
    var emptyImage: some View {
        if isLoading {
            ProgressView()
                .scaleEffect(2)
                .foregroundStyle(EAColor.infoMain)
                .frame(width: 200, height: 200)
        } else {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 200, height: 200)
                .foregroundStyle(EAColor.infoMain)
        }
    }
}
