//
//  ArticlesFiltersView.swift
//  GameSearch
//
//  Created by Codex on 17.04.2026.
//

import SwiftUI

struct ArticlesFiltersView: View {
    let selectedFilter: ArticlesFilter
    let onSelect: (ArticlesFilter) -> Void
    @Namespace private var filterAnimation

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(ArticlesFilter.allCases) { filter in
                    filterCell(for: filter)
                }
            }
            .padding(4)
            .background(EAColor.secondaryBackground.opacity(0.5))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(EAColor.textSecondary.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }
}

private extension ArticlesFiltersView {
    func filterCell(for filter: ArticlesFilter) -> some View {
        let isSelected = selectedFilter == filter
        return Button {
            onSelect(filter)
        } label: {
            Text(filter.title)
                .font(EAFont.infoBold)
                .foregroundStyle(isSelected ? EAColor.textPrimary : EAColor.textSecondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(EAColor.background.opacity(0.9))
                            .stroke(EAColor.accent.opacity(0.5), lineWidth: 1)
                            .matchedGeometryEffect(id: "active-filter", in: filterAnimation)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.25), value: isSelected)
    }
}

#Preview {
    ArticlesFiltersView(selectedFilter: .cs2, onSelect: { _ in })
        .padding(10)
        .background(EAColor.background)
}
