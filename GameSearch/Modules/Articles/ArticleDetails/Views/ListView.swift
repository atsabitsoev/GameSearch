//
//  ListView.swift
//  GameSearch
//
//  Created by Ацамаз on 14.12.2025.
//

import SwiftUI

struct ListView: View {
    let indices: Range<Int>
    let data: ListBlockData


    init(data: ListBlockData) {
        self.indices = data.items.indices
        self.data = data
    }


    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(EAColor.info1)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(indices, id: \.self) { index in
                    Text("\(index + 1). " + data.items[index])
                        .font(.system(size: 16, weight: .regular))
                }
            }
            .padding(16)
        }
    }
}
