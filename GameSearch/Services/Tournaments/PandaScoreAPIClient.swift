//
//  PandaScoreAPIClient.swift
//  GameSearch
//
//  Generic HTTP client for PandaScore REST API with retry, rate-limit
//  awareness, and unified error mapping. Returns DTOs, not domain models.
//

import Foundation

// MARK: - Protocol

protocol PandaScoreAPIClientProtocol: Sendable {
    func get<T: Decodable & Sendable>(
        _ type: T.Type,
        path: String,
        query: [URLQueryItem]
    ) async throws -> T
}

// MARK: - Implementation

final class PandaScoreAPIClient: PandaScoreAPIClientProtocol, @unchecked Sendable {

    // MARK: - Constants

    private enum Constants {
        static let host = "https://api.pandascore.co"
        static let timeout: TimeInterval = 8
        static let maxRetries = 2
        static let retryDelaysMs: [UInt64] = [350, 700, 1400]
        static let apiKeyInfoPlistKey = "PandaScoreAPIKey"
    }

    // MARK: - Dependencies

    private let session: URLSession
    private let decoder: JSONDecoder
    private let apiKeyProvider: () -> String?

    // MARK: - Init

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = PandaScoreAPIClient.defaultDecoder(),
        apiKeyProvider: @escaping () -> String? = PandaScoreAPIClient.defaultApiKeyProvider
    ) {
        self.session = session
        self.decoder = decoder
        self.apiKeyProvider = apiKeyProvider
    }

    static func defaultDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static var defaultApiKeyProvider: () -> String? {
        {
            guard let key = Bundle.main.object(forInfoDictionaryKey: Constants.apiKeyInfoPlistKey) as? String,
                  !key.isEmpty
            else { return nil }
            return key
        }
    }

    // MARK: - Public

    func get<T: Decodable & Sendable>(
        _ type: T.Type,
        path: String,
        query: [URLQueryItem]
    ) async throws -> T {
        guard let apiKey = apiKeyProvider() else {
            throw TournamentsServiceError.missingApiKey
        }
        let url = try buildURL(path: path, query: query)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = Constants.timeout
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return try await performWithRetry(request: request, attempt: 0)
    }
}

// MARK: - Private

private extension PandaScoreAPIClient {

    func buildURL(path: String, query: [URLQueryItem]) throws -> URL {
        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        guard var components = URLComponents(string: Constants.host + normalizedPath) else {
            throw TournamentsServiceError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else {
            throw TournamentsServiceError.invalidURL
        }
        return url
    }

    func performWithRetry<T: Decodable & Sendable>(
        request: URLRequest,
        attempt: Int
    ) async throws -> T {
        do {
            return try await performSingle(request: request)
        } catch let error as TournamentsServiceError {
            guard shouldRetry(error: error), attempt < Constants.maxRetries else {
                throw error
            }
            let delayIndex = min(attempt, Constants.retryDelaysMs.count - 1)
            let delayNs = Constants.retryDelaysMs[delayIndex] * 1_000_000
            try? await Task.sleep(nanoseconds: delayNs)
            return try await performWithRetry(request: request, attempt: attempt + 1)
        }
    }

    func shouldRetry(error: TournamentsServiceError) -> Bool {
        switch error {
        case .noNetwork:
            return true
        case .serverError(let status):
            // Retry only on 5xx and on 408 Request Timeout. 4xx responses
            // (404, 400, etc.) are deterministic — re-trying them wastes
            // rate-limit budget for the same answer.
            return status >= 500 || status == 408
        case .cancelled, .rateLimited, .unauthorized, .missingApiKey,
             .invalidURL, .decoding, .unknown:
            return false
        }
    }

    func performSingle<T: Decodable & Sendable>(request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw TournamentsServiceError.wrap(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TournamentsServiceError.unknown(message: "Non-HTTP response")
        }
        let status = httpResponse.statusCode

        switch status {
        case 200..<300:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw TournamentsServiceError.decoding(message: String(describing: error))
            }
        case 401, 403:
            throw TournamentsServiceError.unauthorized
        case 429:
            let retryAfter = retryAfterSeconds(from: httpResponse)
            throw TournamentsServiceError.rateLimited(retryAfter: retryAfter)
        case 500..<600:
            throw TournamentsServiceError.serverError(status: status)
        default:
            throw TournamentsServiceError.serverError(status: status)
        }
    }

    func retryAfterSeconds(from response: HTTPURLResponse) -> TimeInterval {
        let header = response.value(forHTTPHeaderField: "Retry-After")
        if let header, let seconds = TimeInterval(header) {
            return seconds
        }
        return 60
    }
}
