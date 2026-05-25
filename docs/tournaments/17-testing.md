# 17 — Testing Strategy

Стратегия тестирования модуля «Турниры». Прагматичный подход: тестируем то, где ломается тихо и больно, не тестируем то, где сломается громко и заметно.

---

## Что тестируем (приоритеты)

### Высокий приоритет — обязательно

1. **Mappers** (DTO → Domain). Самое хрупкое место — изменения в API могут проходить незамеченными.
2. **Services** (TournamentsService, MatchesService) — особенно логика кэша (что прочитали из L1, что из L2, что из сети).
3. **Deeplink parser** — критичен для push-уведомлений.
4. **Date formatters** — легко сломать локалью.
5. **Interactors** — бизнес-логика (группировка, сортировка, фильтрация).

### Средний приоритет — желательно

6. **ViewModels** — state transitions (loading → loaded → error).
7. **API client** — retry logic, rate-limit handling.
8. **Cache** — TTL логика, invalidation.

### Низкий приоритет — не тестируем

- **SwiftUI Views** — Preview достаточно, snapshot-тесты в SwiftUI сложно поддерживать.
- **Простые getters/setters** в моделях.
- **Адаптеры к системным API** (UIApplication.shared.open).

---

## Структура тестов

```
GameSearchTests/
└── Tournaments/
    ├── Mappers/
    │   ├── TournamentMapperTests.swift
    │   ├── MatchMapperTests.swift
    │   ├── TeamMapperTests.swift
    │   └── PlayerMapperTests.swift
    ├── Services/
    │   ├── TournamentsServiceTests.swift
    │   ├── MatchesServiceTests.swift
    │   └── PandaScoreAPIClientTests.swift
    ├── Cache/
    │   ├── MemoryCacheTests.swift
    │   ├── DiskCacheTests.swift
    │   └── CacheStoreTests.swift
    ├── Interactors/
    │   ├── TournamentsListInteractorTests.swift
    │   └── TournamentDetailsInteractorTests.swift
    ├── ViewModels/
    │   ├── TournamentsListViewModelTests.swift
    │   └── TournamentDetailsViewModelTests.swift
    ├── Routing/
    │   └── DeeplinkParserTests.swift
    ├── Formatters/
    │   ├── DateFormattersTests.swift
    │   └── PrizepoolFormatterTests.swift
    └── Fixtures/
        ├── PandaScoreFixtures.swift
        └── JSON/
            ├── tournament_running_cs2.json
            ├── tournament_details.json
            ├── match_running.json
            ├── match_finished.json
            └── lives.json
```

---

## Mappers — pattern

Тесты mappers — это **snapshot JSON → ожидаемая модель**.

```swift
import XCTest
@testable import GameSearch

final class TournamentMapperTests: XCTestCase {

    func test_map_runningTournament_mapsAllFields() throws {
        // Given
        let json = try fixture("tournament_running_cs2.json")
        let dto = try JSONDecoder().decode(PandaScoreTournamentDTO.self, from: json)

        // When
        let tournament = try XCTUnwrap(TournamentMapper.map(dto))

        // Then
        XCTAssertEqual(tournament.id, 13420)
        XCTAssertEqual(tournament.slug, "csgo-pgl-major-copenhagen-2026")
        XCTAssertEqual(tournament.tier, .s)
        XCTAssertEqual(tournament.game, .cs2)
        XCTAssertEqual(tournament.league.name, "PGL")
        XCTAssertEqual(tournament.serie.name, "Major Copenhagen 2026")
        XCTAssertEqual(tournament.prizepool?.amount, 1_250_000)
        XCTAssertEqual(tournament.prizepool?.currency, "United States Dollar")
        XCTAssertEqual(tournament.country, "DK")
        XCTAssertNotNil(tournament.beginAt)
    }

    func test_map_missingLeague_returnsNil() throws {
        let json = #"{"id": 1, "slug": "t", "name": "T", "league": null}"#.data(using: .utf8)!
        let dto = try JSONDecoder().decode(PandaScoreTournamentDTO.self, from: json)

        let tournament = TournamentMapper.map(dto)

        XCTAssertNil(tournament)
    }

    func test_map_invalidTier_returnsTournamentWithNilTier() throws {
        // ...
    }
}
```

### Где брать фикстуры

1. Запустить приложение под отладкой.
2. В `PandaScoreAPIClient` временно добавить `print(String(data:, encoding:))` на response.
3. Скопировать JSON.
4. Сохранить в `GameSearchTests/Tournaments/Fixtures/JSON/`.
5. Готово.

Альтернатива: использовать `curl` с реальным API ключом для тестового запроса.

---

## Services — pattern

Тестируем с **mock API client + in-memory cache**.

```swift
final class TournamentsServiceTests: XCTestCase {

    private var apiClient: MockPandaScoreAPIClient!
    private var cache: CacheStore!
    private var sut: TournamentsService!

    override func setUp() {
        super.setUp()
        apiClient = MockPandaScoreAPIClient()
        cache = CacheStore(memory: MemoryCache(), disk: nil) // в тестах диск не нужен
        sut = TournamentsService(api: apiClient, cache: cache)
    }

    func test_fetchTournaments_whenEmptyCache_callsApi() async throws {
        // Given
        apiClient.stubbedTournaments = [.fixture()]

        // When
        let result = try await sut.fetchTournaments(game: .cs2, segment: .running)

        // Then
        XCTAssertEqual(apiClient.callCount, 1)
        XCTAssertEqual(result.count, 1)
    }

    func test_fetchTournaments_whenFreshCache_doesNotCallApi() async throws {
        // Given
        let tournaments = [Tournament.fixture()]
        await cache.write(tournaments, key: "tournaments:list:cs2:running", ttl: 300)

        // When
        let result = try await sut.fetchTournaments(game: .cs2, segment: .running)

        // Then
        XCTAssertEqual(apiClient.callCount, 0)
        XCTAssertEqual(result.count, 1)
    }

    func test_fetchTournaments_whenApiFails_returnsCachedEvenIfStale() async throws {
        // staleWhileRevalidate
    }
}
```

### Mock API client

```swift
final class MockPandaScoreAPIClient: PandaScoreAPIClientProtocol {
    var stubbedTournaments: [PandaScoreTournamentDTO] = []
    var stubbedError: Error?
    var callCount = 0

    func get<T: Decodable>(_ type: T.Type, path: String, query: [URLQueryItem]) async throws -> T {
        callCount += 1
        if let error = stubbedError { throw error }
        if T.self == [PandaScoreTournamentDTO].self {
            return stubbedTournaments as! T
        }
        throw NSError(domain: "Test", code: -1)
    }
}
```

---

## Cache — pattern

```swift
final class MemoryCacheTests: XCTestCase {

    func test_read_afterWrite_returnsValue() async {
        let cache = MemoryCache()
        await cache.write(["a", "b"], key: "test", ttl: 60)

        let result: [String]? = await cache.read([String].self, key: "test")

        XCTAssertEqual(result, ["a", "b"])
    }

    func test_read_afterTTLExpired_returnsNil() async {
        let cache = MemoryCache()
        await cache.write(["a"], key: "test", ttl: 0.1)
        try? await Task.sleep(nanoseconds: 200_000_000)

        let result: [String]? = await cache.read([String].self, key: "test")

        XCTAssertNil(result)
    }

    func test_invalidate_byPrefix_removesMatchingKeys() async {
        // ...
    }
}
```

---

## Deeplink parser

```swift
final class DeeplinkParserTests: XCTestCase {

    func test_parse_validTournamentUrl_returnsTournamentRoute() {
        let url = URL(string: "gamesearch://tournament/csgo-pgl-major")!

        let deeplink = Deeplink.parse(url)

        XCTAssertEqual(deeplink, .tournamentDetails(idOrSlug: "csgo-pgl-major"))
    }

    func test_parse_validMatchUrl_returnsMatchRoute() {
        let url = URL(string: "gamesearch://match/12345")!

        let deeplink = Deeplink.parse(url)

        XCTAssertEqual(deeplink, .matchDetails(id: 12345))
    }

    func test_parse_invalidScheme_returnsNil() {
        let url = URL(string: "https://tournament/12345")!

        let deeplink = Deeplink.parse(url)

        XCTAssertNil(deeplink)
    }

    func test_parse_tournamentsTabWithGame_returnsTabWithGame() {
        let url = URL(string: "gamesearch://tournaments/cs2")!

        let deeplink = Deeplink.parse(url)

        XCTAssertEqual(deeplink, .tournamentsTab(game: .cs2))
    }
}
```

---

## ViewModels

```swift
@MainActor
final class TournamentsListViewModelTests: XCTestCase {

    private var interactor: MockTournamentsListInteractor!
    private var analytics: MockAnalytics!
    private var sut: TournamentsListViewModel!

    override func setUp() {
        super.setUp()
        interactor = MockTournamentsListInteractor()
        analytics = MockAnalytics()
        sut = TournamentsListViewModel(interactor: interactor, analytics: analytics)
    }

    func test_onAppear_transitionsToLoaded() async {
        // Given
        interactor.stubbedData = .init(tournaments: [.fixture()], liveMatches: [])

        // When
        await sut.onAppear()

        // Then
        switch sut.state {
        case .loaded(let tournaments):
            XCTAssertEqual(tournaments.count, 1)
        default:
            XCTFail("Expected .loaded")
        }
    }

    func test_onAppear_whenInteractorThrows_transitionsToError() async {
        interactor.stubbedError = TournamentsServiceError.noNetwork

        await sut.onAppear()

        if case .error(.noInternet) = sut.state { /* ok */ } else { XCTFail() }
    }

    func test_onAppear_reportsAnalyticsEvent() async {
        await sut.onAppear()

        XCTAssertTrue(analytics.reportedEvents.contains(where: { $0.name == "tournaments_tab_opened" }))
    }
}
```

---

## Fixtures helpers

```swift
extension Tournament {
    static func fixture(
        id: TournamentId = 1,
        slug: String = "test-tournament",
        name: String = "Test",
        tier: Tier? = .s,
        game: Game = .cs2
    ) -> Tournament {
        Tournament(
            id: id,
            slug: slug,
            name: name,
            tier: tier,
            game: game,
            league: .init(id: 1, name: "Test League", slug: "test-league", imageUrl: nil),
            serie: .init(id: 1, name: "Test Serie", fullName: nil, year: 2026, season: nil),
            beginAt: Date(),
            endAt: Date().addingTimeInterval(86400 * 10),
            prizepool: nil,
            country: "RU",
            region: nil,
            liveSupported: false,
            modifiedAt: nil,
            matches: nil,
            participants: nil
        )
    }
}
```

---

## Запуск тестов

### Через MCP (предпочтительно)

Из правил проекта (`AGENTS.md`):

```
RunAllTests (xcode-tools)         — все тесты
RunSomeTests (xcode-tools)        — выборочно
GetTestList (xcode-tools)         — список тестов
```

### Через CLI (fallback)

```bash
xcodebuild test \
  -project GameSearch.xcodeproj \
  -scheme GameSearch \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

## Continuous integration

В MVP — CI не настраиваем (один разработчик/агент). В Phase 3+ можно завести GitHub Actions:

```yaml
- name: Run tests
  run: xcodebuild test -project GameSearch.xcodeproj -scheme GameSearch \
                       -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

## Покрытие кода

Целевые показатели coverage **по приоритетам**:

| Зона | Цель coverage |
|---|---|
| Mappers | **90%+** |
| Services | **80%+** |
| Interactors | **70%+** |
| Cache | **80%+** |
| Deeplink parser | **100%** |
| ViewModels | **60%+** (главные state-transitions) |
| Views | не измеряем |

Coverage не самоцель — главное чтобы критические сценарии были покрыты.

---

## UI testing

UI-тесты через XCUITest **в MVP не делаем**. Слишком хрупкие, дорого поддерживать.

Альтернатива:
1. **Превью каждого экрана** для визуальной проверки.
2. **Ручной прогон** через симулятор перед каждым релизом фазы.
3. **Скриншоты через XcodeBuildMCP** в чате при крупных изменениях.

В Phase 4+ — можно добавить XCUITest для критичных flows (purchase, push, deeplink), если они появятся.

---

## Performance тесты

В MVP не делаем. В Phase 3+ можно добавить:
- Тест на скорость рендера большого списка (1000 турниров).
- Тест на потребление памяти при долгом скролле.
- Тест на размер диск-кэша после интенсивного использования.

---

_Last updated: 2026-05-25_
