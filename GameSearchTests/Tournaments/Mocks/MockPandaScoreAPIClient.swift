//
//  MockPandaScoreAPIClient.swift
//  GameSearchTests
//

import Foundation
@testable import GameSearch

final class MockPandaScoreAPIClient: PandaScoreAPIClientProtocol, @unchecked Sendable {

    struct Call: Hashable {
        let path: String
        let query: [URLQueryItem]
    }

    var callCount = 0
    private(set) var calls: [Call] = []

    var stubbedError: Error?
    var responseHandler: ((String, [URLQueryItem]) throws -> Any)?

    func get<T: Decodable & Sendable>(
        _ type: T.Type,
        path: String,
        query: [URLQueryItem]
    ) async throws -> T {
        callCount += 1
        calls.append(Call(path: path, query: query))
        if let stubbedError {
            throw stubbedError
        }
        guard let responseHandler else {
            throw TournamentsServiceError.unknown(message: "MockPandaScoreAPIClient missing responseHandler for \(path)")
        }
        let result = try responseHandler(path, query)
        guard let typed = result as? T else {
            throw TournamentsServiceError.unknown(
                message: "Stub for \(path) returned \(Swift.type(of: result)); expected \(T.self)"
            )
        }
        return typed
    }
}
