//
//  SwipeSegmentedView.swift
//  GameSearch
//
//  Created by Ацамаз on 22.05.2025.
//

import SwiftUI

struct SwipeSegmentedView<Content: View>: View {
    let sections: [DetailsSection]
    @Binding var selectedSegment: DetailsSection
    @ViewBuilder let content: (DetailsSection) -> Content

    init(
        _ sections: [DetailsSection],
        initialSegment: Binding<DetailsSection>,
        @ViewBuilder content: @escaping (DetailsSection) -> Content
    ) {
        self.sections = sections
        self._selectedSegment = initialSegment
        self.content = content
    }


    var body: some View {
        VStack(spacing: 0) {
            SectionPicker(sections: sections, selectedSection: $selectedSegment)
                .padding(.horizontal)
            TabView(selection: $selectedSegment) {
                ForEach(sections) { segment in
                    content(segment)
                        .tag(segment)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(duration: 0.3), value: selectedSegment)
        }
    }
}
