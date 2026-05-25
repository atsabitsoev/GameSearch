//
//  Serie.swift
//  GameSearch
//

import Foundation

struct Serie: Identifiable, Hashable, Sendable, Codable {
    let id: SerieId
    let name: String
    let fullName: String?
    let year: Int?
    let season: String?
}
