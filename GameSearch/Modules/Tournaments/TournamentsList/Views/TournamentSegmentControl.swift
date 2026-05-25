//
//  TournamentSegmentControl.swift
//  GameSearch
//
//  Three-segment control to switch between "Сейчас" / "Скоро" / "Прошедшие".
//

import SwiftUI

struct TournamentSegmentControl: View {
    @Binding var selected: TournamentSegment
    var accentColor: Color = EAColor.purpleAccent

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TournamentSegment.allCases, id: \.self) { segment in
                segmentButton(for: segment)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.55))
        )
    }
}

private extension TournamentSegmentControl {
    func segmentButton(for segment: TournamentSegment) -> some View {
        let isSelected = selected == segment
        return Button {
            guard selected != segment else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                selected = segment
            }
        } label: {
            Text(segment.localizedTitle)
                .font(EAFont.smallTitle)
                .foregroundStyle(isSelected ? EAColor.textPrimary : EAColor.textSecondary)
                .frame(maxWidth: .infinity)
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
    }
}

private extension TournamentSegment {
    var localizedTitle: String {
        switch self {
        case .running: TournamentsStrings.segmentRunning
        case .upcoming: TournamentsStrings.segmentUpcoming
        case .past: TournamentsStrings.segmentPast
        }
    }
}

#Preview {
    @Previewable @State var segment: TournamentSegment = .running
    return TournamentSegmentControl(selected: $segment)
        .padding()
        .background(EAColor.background)
        .preferredColorScheme(.dark)
}
