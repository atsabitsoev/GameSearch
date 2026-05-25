//
//  LiveMatchesStrip.swift
//  GameSearch
//
//  Horizontal scrollable strip of live `LiveMatchChip`s. Hidden when
//  there are zero live matches (we do not render an empty section).
//

import SwiftUI

struct LiveMatchesStrip: View {
    let matches: [Match]
    let onTap: (Match, Int) -> Void

    var body: some View {
        if matches.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text(TournamentsStrings.liveStripTitle)
                    .font(EAFont.smallTitle)
                    .foregroundStyle(EAColor.textPrimary)
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(matches.enumerated()), id: \.element.id) { index, match in
                            Button {
                                onTap(match, index)
                            } label: {
                                LiveMatchChip(match: match)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}
