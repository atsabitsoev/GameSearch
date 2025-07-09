//
//  ExpandableText.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 09.07.2025.
//

import SwiftUI


struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    let font: Font
    let textColor: Color = EAColor.textPrimary
    
    @State private var expanded = false
    @State private var truncated = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(font)
                .foregroundStyle(textColor)
                .lineLimit(expanded ? nil : lineLimit)
                .background(hiddenGeoText)
                .onTapGesture { toggleExpand() }
            
            if truncated {
                truncatedButton
            }
        }
    }
    
    
}

private extension ExpandableText {
    var truncatedButton: some View {
        Button { toggleExpand() }
        label: {
            Text(expanded ? "Свернуть" : "Еще")
                .foregroundColor(EAColor.accentGradient)
        }
    }
    
    var hiddenGeoText: some View {
        Text(text)
            .font(font)
            .lineLimit(lineLimit)
            .background(GeometryReader { visibleGeometry in
                Color.clear.onAppear {
                    let visibleHeight = visibleGeometry.size.height
                    let fullHeight = text.height(
                        withConstrainedWidth: UIScreen.main.bounds.width - 40,
                        font: UIFont.systemFont(ofSize: UIFont.labelFontSize)
                    )
                    truncated = fullHeight > visibleHeight + 1
                }
            })
            .hidden()
    }
    
    func toggleExpand() {
        withAnimation(.spring) { expanded.toggle() }
    }
}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
