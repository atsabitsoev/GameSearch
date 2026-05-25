//
//  Bracket.swift
//  GameSearch
//

import Foundation

struct Bracket: Hashable, Sendable, Codable {
    let rounds: [Round]

    struct Round: Hashable, Sendable, Codable {
        let name: String
        let matches: [Match]
    }
}
