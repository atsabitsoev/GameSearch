//
//  GameSegmentControl.swift
//  GameSearch
//
//  Two-segment control to switch between CS2 and Dota 2. Each segment
//  uses the brand color of the corresponding game.
//

import SwiftUI

struct GameSegmentControl: View {
    @Binding var selected: Game

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Game.allCases, id: \.self) { game in
                segmentButton(for: game)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(EAColor.secondaryBackground.opacity(0.55))
        )
    }
}

private extension GameSegmentControl {
    func segmentButton(for game: Game) -> some View {
        let isSelected = selected == game
        let accent = GameAccentColor.color(for: game)
        return Button {
            guard selected != game else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                selected = game
            }
        } label: {
            HStack(spacing: 6) {
                Image(GameAccentColor.iconName(for: game))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text(game.displayName)
                    .font(EAFont.smallTitle)
                    .foregroundStyle(isSelected ? EAColor.textPrimary : EAColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? accent.opacity(0.22) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? accent.opacity(0.6) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityLabel(Text(game.displayName))
    }
}

#Preview {
    StatefulPreviewWrapper(Game.cs2) { binding in
        GameSegmentControl(selected: binding)
            .padding()
            .background(EAColor.background)
    }
    .preferredColorScheme(.dark)
}

private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> Content

    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initial)
        self.content = content
    }

    var body: some View { content($value) }
}
