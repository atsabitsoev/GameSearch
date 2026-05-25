//
//  Stream.swift
//  GameSearch
//

import Foundation

struct Stream: Hashable, Sendable, Codable, Identifiable {
    let id: String
    let language: String
    let rawUrl: URL
    let embedUrl: URL?
    let main: Bool
    let official: Bool
    let platform: StreamPlatform
}
