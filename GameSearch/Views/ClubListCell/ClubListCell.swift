//
//  ClubListCell.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 13.05.2025.
//

import SwiftUI

struct ClubListCell: View {
    private let club: FullClubData
    
    init(club: FullClubData) {
        self.club = club
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .bottomTrailing, endPoint: .topLeading))
                .frame(height: 160)
            Text("\(club.name)")
        }
    }
}

#Preview {
    ClubListCell(club: FullClubData.mock[0])
}
