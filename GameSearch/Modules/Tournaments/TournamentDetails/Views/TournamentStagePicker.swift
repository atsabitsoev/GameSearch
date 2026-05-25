//
//  TournamentStagePicker.swift
//  GameSearch
//
//  Horizontal segmented picker for sibling stages of a series — e.g.
//  "Group Stage · Playoffs" or "Group A · Group B · Playoffs". Shown
//  in `TournamentDetailsView` above the tab picker when the series
//  has more than one stage.
//
//  Without this picker the user could open one stage from the list but
//  had no way to switch between Group Stage (where PandaScore returns
//  full W/L/Карты statistics) and Playoffs (just the bracket ranking).
//

import SwiftUI

struct TournamentStagePicker: View {
    let stages: [Tournament]
    let selectedStageId: TournamentId
    var accentColor: Color = EAColor.purpleAccent
    let onSelect: (Tournament) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(stages) { stage in
                    chip(for: stage)
                }
            }
            .padding(4)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.55))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Стадии турнира"))
    }
}

private extension TournamentStagePicker {
    func chip(for stage: Tournament) -> some View {
        let isSelected = stage.id == selectedStageId
        let title = stage.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Стадия"
            : stage.name
        return Button {
            guard !isSelected else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                onSelect(stage)
            }
        } label: {
            Text(title)
                .font(EAFont.info)
                .fontWeight(isSelected ? .bold : .regular)
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
        .accessibilityLabel(Text(title))
    }
}

#Preview {
    let league = League(id: 1, name: "PGL", slug: "pgl", imageUrl: nil)
    let serie = Serie(id: 1, name: "Astana 2026", fullName: "Astana 2026", year: 2026, season: nil)
    func stage(id: Int, name: String) -> Tournament {
        Tournament(
            id: id, slug: "s\(id)", name: name, tier: .a, game: .cs2,
            league: league, serie: serie,
            beginAt: Date().addingTimeInterval(TimeInterval(id) * 86400),
            endAt: Date().addingTimeInterval(TimeInterval(id + 1) * 86400),
            prizepool: nil, country: "KZ", region: "ASIA",
            liveSupported: false, modifiedAt: nil,
            matches: nil, participants: nil
        )
    }
    let stages = [stage(id: 1, name: "Group Stage"), stage(id: 2, name: "Playoffs")]
    return VStack(spacing: 16) {
        TournamentStagePicker(stages: stages, selectedStageId: 1, onSelect: { _ in })
            .padding()
        TournamentStagePicker(
            stages: [
                stage(id: 1, name: "Group A"),
                stage(id: 2, name: "Group B"),
                stage(id: 3, name: "Playoffs"),
                stage(id: 4, name: "Grand Final")
            ],
            selectedStageId: 3,
            onSelect: { _ in }
        )
        .padding()
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
