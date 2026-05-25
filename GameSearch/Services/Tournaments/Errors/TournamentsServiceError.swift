//
//  TournamentsServiceError.swift
//  GameSearch
//
//  Unified error type for all Tournaments-module services and the
//  PandaScore API client.
//

import Foundation

enum TournamentsServiceError: Error, Equatable {
    case noNetwork
    case rateLimited(retryAfter: TimeInterval)
    case serverError(status: Int)
    case decoding(message: String)
    case unauthorized
    case missingApiKey
    case invalidURL
    case unknown(message: String)
}

extension TournamentsServiceError {
    static func wrap(_ error: Error) -> TournamentsServiceError {
        if let mapped = error as? TournamentsServiceError {
            return mapped
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed,
                 .timedOut, .cannotFindHost, .cannotConnectToHost, .internationalRoamingOff:
                return .noNetwork
            default:
                return .unknown(message: urlError.localizedDescription)
            }
        }
        if error is DecodingError {
            return .decoding(message: String(describing: error))
        }
        return .unknown(message: error.localizedDescription)
    }
}
