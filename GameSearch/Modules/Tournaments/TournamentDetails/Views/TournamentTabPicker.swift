//
//  TournamentTabPicker.swift
//  GameSearch
//
//  Four-tab picker for `TournamentDetailsView`: Матчи / Таблица / Сетка /
//  Команды. Mirrors the visual language of `TournamentSegmentControl`
//  (Phase 1.A) for consistency across the module. Wrapped in a
//  ScrollView to stay readable on the narrowest iPhones with longer
//  Russian labels.
//
//  Note: `08-modules-and-files.md` suggested reusing `SwipeSegmentedView`,
//  but that component is hardcoded to the Clubs-specific `DetailsSection`
//  enum and to the heavier `TabView(.page)` swipe pattern. We chose to
//  follow the lighter pattern from Phase 1.A here. If we need swipe-
//  between-tabs later, generalising `SwipeSegmentedView` to be generic
//  over its tag type is the cleanest follow-up — captured for Phase 4
//  polish.
//

import SwiftUI

struct TournamentTabPicker: View {
    @Binding var selected: TournamentDetailsTab
    var accentColor: Color = EAColor.purpleAccent

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(TournamentDetailsTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(4)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.55))
        )
    }
}

private extension TournamentTabPicker {
    func tabButton(for tab: TournamentDetailsTab) -> some View {
        let isSelected = selected == tab
        return Button {
            guard selected != tab else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                selected = tab
            }
        } label: {
            Text(tab.title)
                .font(EAFont.smallTitle)
                .foregroundStyle(isSelected ? EAColor.textPrimary : EAColor.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? accentColor.opacity(0.22) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isSelected ? accentColor.opacity(0.6) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityLabel(Text(tab.title))
    }
}

#Preview {
    @Previewable @State var selected: TournamentDetailsTab = .matches
    return VStack(spacing: 16) {
        TournamentTabPicker(selected: $selected)
            .padding()
        Text("Selected: \(selected.title)")
            .foregroundStyle(EAColor.textPrimary)
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
