//
//  ClubListResponse.swift
//  GameSearch
//
//  Created by Бабочиев Эдуард Таймуразович on 01.07.2025.
//

struct ClubListResponse: Codable {
    let html: String
    let last: Int
    let current: Int
    let total: Int
    let hasMoreClubs: Bool
    let totalForView: Int
}
