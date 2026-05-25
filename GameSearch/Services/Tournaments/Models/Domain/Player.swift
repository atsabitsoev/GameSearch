//
//  Player.swift
//  GameSearch
//

import Foundation

struct Player: Identifiable, Hashable, Sendable, Codable {
    let id: PlayerId
    let nickname: String
    let firstName: String?
    let lastName: String?
    let nationality: String?
    let age: Int?
    let birthday: Date?
    let role: String?
    let active: Bool
    let imageUrl: URL?
    let currentTeam: Team?
    let currentGame: Game?

    var displayFullName: String? {
        switch (firstName, lastName) {
        case (let first?, let last?): "\(first) \(last)"
        case (let first?, nil): first
        case (nil, let last?): last
        default: nil
        }
    }
}
