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
                .fill(Color(white: 0.2))
                .shadow(color: Color.white, radius: 0, x: 0, y: 1)
                .opacity(0.4)
            VStack {
                HStack {
                    Text(club.name)
                        .foregroundStyle(Color.white)
                        .fontWeight(Font.Weight.bold)
                        .font(Font.title2)
                    Spacer()
                    Label("4.9", systemImage: "star.fill")
                        .foregroundStyle(Color.yellow)
                }
                Spacer()
                    .frame(height: 16)
                HStack {
                    Label("RTX 4070 Ti", systemImage: "cpu.fill")
                        .foregroundStyle(Color.red)
                        .shadow(color: Color.black.opacity(0.5), radius: 7)
                    Spacer()
                }
                Spacer()
                    .frame(height: 8)
                HStack {
                    Label("140₽/час", systemImage: "banknote.fill")
                        .foregroundStyle(Color.green)
                        .shadow(color: Color.black.opacity(0.5), radius: 7)
                    Spacer()
                    Label("\(Int.random(in: 100...800)) м", systemImage: "location")
                        .foregroundStyle(Color.white)
                        .shadow(color: Color.black.opacity(0.5), radius: 7)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ClubListCell(club: FullClubData.mock[0])
}
