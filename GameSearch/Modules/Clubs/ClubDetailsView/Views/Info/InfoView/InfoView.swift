//
//  InfoView.swift
//  GameSearch
//
//  Created by Ацамаз on 29.05.2025.
//

import SwiftUI


struct InfoView: View {
    let info: InfoData
    
    init(_ info: InfoData) {
        self.info = info
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(info.title)
                    .font(.headline)
                    .foregroundStyle(EAColor.info2)
                ExpandableText(
                    text: info.desc,
                    lineLimit: 5,
                    font: .body
                )
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(EAColor.info1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
