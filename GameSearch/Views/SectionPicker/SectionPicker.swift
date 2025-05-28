//
//  SectionPicker.swift
//  GameSearch
//
//  Created by Ацамаз on 21.05.2025.
//

import SwiftUI


struct SectionPicker: View {
    let sections: [DetailsSection]
    @Binding var selectedSection: DetailsSection


    var body: some View {
        segmentsView
        indicatorView
    }


    private var segmentsView: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(sections) { section in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedSection = section
                        }
                    }) {
                        Text(section.title)
                            .foregroundColor(selectedSection == section ? EAColor.accent : EAColor.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                }
            }
            .background(EAColor.accent.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top)
        }
    }

    private var indicatorView: some View {
        GeometryReader { geometry in
            let itemWidth = geometry.size.width / CGFloat(sections.count)
            RoundedRectangle(cornerRadius: 1)
                .fill(EAColor.accent)
                .frame(width: itemWidth - 32, height: 2)
                .offset(x: itemWidth * CGFloat(selectedIndex) + 16, y: 0)
                .animation(.easeInOut(duration: 0.3), value: selectedIndex)
        }
        .frame(height: 2)
    }

    private var selectedIndex: Int {
        get {
            sections.firstIndex(of: selectedSection) ?? 0
        }
        set {
            selectedSection = sections[newValue]
        }
    }
}

struct AnimatedPicker_Previews: PreviewProvider {
    static var previews: some View {
        SectionPicker(sections: [.common, .specification], selectedSection: .constant(.common))
            .padding()
    }
}
