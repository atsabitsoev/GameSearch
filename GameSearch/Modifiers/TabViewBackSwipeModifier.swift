//
//  TabViewBackSwipeModifier.swift
//  GameSearch
//
//  Created by Ацамаз on 22.05.2025.
//

import SwiftUI


struct TabViewBackSwipe: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay {
                HStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.0001))
                        .frame(width: 24)
                    Spacer()
                }
            }
    }
}

extension View {
    func dontBlockBackSwipe() -> some View {
        self
            .modifier(TabViewBackSwipe())
    }
}
