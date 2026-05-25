//
//  PandaScoreStreamDTO.swift
//  GameSearch
//

import Foundation

struct PandaScoreStreamDTO: Decodable, Sendable {
    let language: String?
    let embedUrl: String?
    let rawUrl: String?
    let main: Bool?
    let official: Bool?
}
