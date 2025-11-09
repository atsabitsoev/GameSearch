//
//  CornersModifier.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 11.06.2025.
//

import SwiftUI

struct CornersModifier: ViewModifier {
    let topLeading: CGFloat
    let topTrailing: CGFloat
    let bottomLeading: CGFloat
    let bottomTrailing: CGFloat
    
    func body(content: Content) -> some View {
        content
            .clipShape(.rect(
                topLeadingRadius: topLeading,
                bottomLeadingRadius: bottomLeading,
                bottomTrailingRadius: bottomTrailing,
                topTrailingRadius: topTrailing
            ))
    }
}

extension View {
    func cornersRadius(topLeading: CGFloat = 0, topTrailing: CGFloat = 0, bottomLeading: CGFloat = 0, bottomTrailing: CGFloat = 0) -> some View {
        self
            .modifier(
                CornersModifier(
                    topLeading: topLeading,
                    topTrailing: topTrailing,
                    bottomLeading: bottomLeading,
                    bottomTrailing: bottomTrailing
                )
            )
    }
    
    func cornersRadius(top: CGFloat = 0, bottom: CGFloat = 0) -> some View {
        self
            .modifier(
                CornersModifier(
                    topLeading: top,
                    topTrailing: top,
                    bottomLeading: bottom,
                    bottomTrailing: bottom
                )
            )
    }
    
    func cornersRadius(_ radius: CGFloat) -> some View {
        self
            .modifier(
                CornersModifier(
                    topLeading: radius,
                    topTrailing: radius,
                    bottomLeading: radius,
                    bottomTrailing: radius
                )
            )
    }
}
