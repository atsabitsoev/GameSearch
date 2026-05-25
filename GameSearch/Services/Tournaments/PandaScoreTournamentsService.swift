import Foundation

protocol PlaceholderTournamentsServiceProtocol {
    func fetchTopTournaments() async -> [TournamentHeadline]
}

struct TournamentHeadline: Hashable {
    let game: TournamentGame
    let title: String
}

enum TournamentGame: String, Hashable {
    case cs2 = "CS2"
    case dota2 = "Dota 2"
}


//TODO: - Удалить после Phase 1: TournamentsService и TournamentsListView заменят этот placeholder.
final class PandaScoreTournamentsService: PlaceholderTournamentsServiceProtocol {
    private let session: URLSession
    private let defaults = UserDefaults.standard
    private let apiHost = "https://api.pandascore.co"
    private let cacheTTL: TimeInterval = 60 * 10
    private static var inFlightTask: Task<[TournamentHeadline], Never>?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchTopTournaments() async -> [TournamentHeadline] {
        let freshCached = freshCachedHeadlines()
        if freshCached.count == 2 {
            return freshCached
        }

        if let inFlightTask = Self.inFlightTask {
            return await inFlightTask.value
        }

        let task = Task<[TournamentHeadline], Never> {
            await fetchTopTournamentsFromNetworkIfNeeded(prefilled: freshCached)
        }
        Self.inFlightTask = task
        let result = await task.value
        Self.inFlightTask = nil
        return result
    }
}

private extension PandaScoreTournamentsService {
    func fetchTopTournamentsFromNetworkIfNeeded(prefilled freshCached: [TournamentHeadline]) async -> [TournamentHeadline] {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PandaScoreAPIKey") as? String,
              !apiKey.isEmpty
        else {
            return cachedHeadlines()
        }

        let freshByGame = Dictionary(uniqueKeysWithValues: freshCached.map { ($0.game, $0) })

        async let cs2Result: TournamentHeadline? = {
            if let cached = freshByGame[.cs2] { return cached }
            if let network = await fetchTopTournament(for: .cs2, apiKey: apiKey) {
                cache(network)
                cacheTimestamp(for: .cs2)
                return network
            }
            return cachedHeadline(for: .cs2)
        }()

        async let dota2Result: TournamentHeadline? = {
            if let cached = freshByGame[.dota2] { return cached }
            if let network = await fetchTopTournament(for: .dota2, apiKey: apiKey) {
                cache(network)
                cacheTimestamp(for: .dota2)
                return network
            }
            return cachedHeadline(for: .dota2)
        }()

        var headlines: [TournamentHeadline] = []
        if let cs2 = await cs2Result {
            headlines.append(cs2)
        }

        if let dota2 = await dota2Result {
            headlines.append(dota2)
        }

        return headlines
    }
    func fetchTopTournament(for game: TournamentGame, apiKey: String) async -> TournamentHeadline? {
        if let live = await fetchTournament(for: game, pathSuffix: "running", apiKey: apiKey),
           let title = compactTournamentTitle(from: live) {
            return .init(game: game, title: title)
        }
        if let upcoming = await fetchTournament(for: game, pathSuffix: "upcoming", apiKey: apiKey),
           let title = compactTournamentTitle(from: upcoming) {
            return .init(game: game, title: title)
        }
        return nil
    }

    func fetchTournament(
        for game: TournamentGame,
        pathSuffix: String,
        apiKey: String
    ) async -> PandaScoreTournament? {
        guard let url = buildURL(for: game, pathSuffix: pathSuffix) else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 8

        guard let tournaments: [PandaScoreTournament] = await performRequest(request, retries: 2) else {
            return nil
        }
        return tournaments.first
    }

    func buildURL(for game: TournamentGame, pathSuffix: String) -> URL? {
        let gamePath: String = switch game {
        case .cs2:
            "csgo"
        case .dota2:
            "dota2"
        }
        guard var components = URLComponents(string: "\(apiHost)/\(gamePath)/tournaments/\(pathSuffix)") else {
            return nil
        }
        components.queryItems = [
            .init(name: "filter[tier]", value: "s,a"),
            .init(name: "page[size]", value: "20"),
            .init(name: "sort", value: pathSuffix == "running" ? "-begin_at" : "begin_at")
        ]
        return components.url
    }

    func performRequest<T: Decodable>(_ request: URLRequest, retries: Int) async -> T? {
        var attempt = 0
        while attempt <= retries {
            if let decoded: T = await performSingleRequest(request) {
                return decoded
            }
            attempt += 1
            if attempt <= retries {
                try? await Task.sleep(nanoseconds: 350_000_000)
            }
        }
        return nil
    }

    func performSingleRequest<T: Decodable>(_ request: URLRequest) async -> T? {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                return nil
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    func compactTournamentTitle(from tournament: PandaScoreTournament) -> String? {
        let league = tournament.league?.name
        let series = tournament.serie?.name

        if let league, let series {
            return "\(league) \(series)"
        }
        return nil
    }

    func cache(_ headline: TournamentHeadline) {
        defaults.set(headline.title, forKey: cacheKey(for: headline.game))
    }

    func cachedHeadline(for game: TournamentGame) -> TournamentHeadline? {
        guard let title = defaults.string(forKey: cacheKey(for: game)), !title.isEmpty else { return nil }
        return .init(game: game, title: title)
    }

    func cachedHeadlines() -> [TournamentHeadline] {
        var result: [TournamentHeadline] = []
        if let cs2 = cachedHeadline(for: .cs2) {
            result.append(cs2)
        }
        if let dota2 = cachedHeadline(for: .dota2) {
            result.append(dota2)
        }
        return result
    }

    func freshCachedHeadlines() -> [TournamentHeadline] {
        var result: [TournamentHeadline] = []
        if let cs2 = freshCachedHeadline(for: .cs2) {
            result.append(cs2)
        }
        if let dota2 = freshCachedHeadline(for: .dota2) {
            result.append(dota2)
        }
        return result
    }

    func freshCachedHeadline(for game: TournamentGame) -> TournamentHeadline? {
        guard let cached = cachedHeadline(for: game) else { return nil }
        let updatedAt = defaults.double(forKey: cacheTimestampKey(for: game))
        guard updatedAt > 0 else { return nil }
        let isFresh = Date().timeIntervalSince1970 - updatedAt <= cacheTTL
        return isFresh ? cached : nil
    }

    func cacheTimestamp(for game: TournamentGame) {
        defaults.set(Date().timeIntervalSince1970, forKey: cacheTimestampKey(for: game))
    }

    func cacheKey(for game: TournamentGame) -> String {
        switch game {
        case .cs2:
            "pandascore.cached.cs2"
        case .dota2:
            "pandascore.cached.dota2"
        }
    }

    func cacheTimestampKey(for game: TournamentGame) -> String {
        switch game {
        case .cs2:
            "pandascore.cached.ts.cs2"
        case .dota2:
            "pandascore.cached.ts.dota2"
        }
    }
}

private struct PandaScoreTournament: Decodable {
    let league: PandaScoreNamedEntity?
    let serie: PandaScoreNamedEntity?
}

private struct PandaScoreNamedEntity: Decodable {
    let name: String?
}
