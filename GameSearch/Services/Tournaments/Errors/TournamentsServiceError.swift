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
    /// Request was cancelled (URLSession cancellation or Swift Task cancellation).
    /// Treated separately from real errors so view-models can ignore it and
    /// not flip the screen into `.error` state on pull-to-refresh / view-life-
    /// cycle cancellations.
    case cancelled
    case unknown(message: String)
}

extension TournamentsServiceError {
    static func wrap(_ error: Error) -> TournamentsServiceError {
        if let mapped = error as? TournamentsServiceError {
            return mapped
        }
        if error is CancellationError {
            return .cancelled
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .cancelled:
                return .cancelled
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

// MARK: - Cancellation helper

extension Error {
    /// True for any flavour of cancellation we know about: Swift Task
    /// `CancellationError`, Foundation `URLError(.cancelled)`, and our
    /// own `TournamentsServiceError.cancelled`. Use in view-model catch
    /// blocks to bail out silently instead of surfacing an error state.
    var isCancellation: Bool {
        if self is CancellationError { return true }
        if let urlError = self as? URLError, urlError.code == .cancelled { return true }
        if let mapped = self as? TournamentsServiceError, mapped == .cancelled { return true }
        return false
    }
}
