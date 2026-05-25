//
//  PandaScoreSerieDTO.swift
//  GameSearch
//

import Foundation

struct PandaScoreSerieDTO: Decodable, Sendable {
    let id: Int?
    let name: String?
    let fullName: String?
    let year: Int?
    let season: String?
}
