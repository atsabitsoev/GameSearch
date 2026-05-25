//
//  PandaScoreCommonDTO.swift
//  GameSearch
//
//  Shared low-level DTOs reused across PandaScore endpoints.
//

import Foundation

struct PandaScoreVideogameDTO: Decodable, Sendable {
    let id: Int?
    let name: String?
    let slug: String?
}

struct PandaScoreWinnerRefDTO: Decodable, Sendable {
    let id: Int?
    let type: String?
}

struct PandaScoreImageURLDTO: Decodable, Sendable {
    let imageUrl: String?
}
