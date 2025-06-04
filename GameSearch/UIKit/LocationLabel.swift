//
//  LocationLabel.swift
//  GameSearch
//
//  Created by Ацамаз on 04.06.2025.
//

import SwiftUI


struct LocationLabel: View {
    let address: String

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "mappin.and.ellipse")
            Text(address)
        }
        .symbolRenderingMode(.multicolor)
    }
}
