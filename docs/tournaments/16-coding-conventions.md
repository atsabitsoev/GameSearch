# 16 — Coding Conventions

Конвенции кода для модуля «Турниры». Полностью соответствуют общему стилю проекта GameSearch — для согласованности.

---

## Общие правила

1. **Swift 5.10+**, готовность к **Swift 6 strict concurrency**.
2. **SwiftUI везде в UI**. UIKit — только если SwiftUI не позволяет (примеры в проекте: ZoomAndPanImage).
3. **Async/await** для всей асинхронности. Без Combine pipelines в новом коде.
4. **@MainActor на ViewModel** целиком, не на отдельные поля.
5. **Без force-unwrap (`!`)**. Исключения — только в Preview / тестах.
6. **Без `fatalError()`** в production-коде (кроме `init(coder:)` для UIKit).
7. **2 пробела отступ** (как в существующем коде).
8. **120 символов в строке** soft limit.

---

## Naming

### Файлы

| Что | Шаблон | Пример |
|---|---|---|
| SwiftUI View | `<Feature>View.swift` | `TournamentsListView.swift` |
| ViewModel | `<Feature>ViewModel.swift` | `TournamentsListViewModel.swift` |
| Interactor | `<Feature>Interactor.swift` | `TournamentsListInteractor.swift` |
| Protocols-набор | `<Feature>Protocols.swift` | `TournamentsListProtocols.swift` |
| Service | `<Entity>Service.swift` | `TournamentsService.swift` |
| Domain model | `<Entity>.swift` | `Tournament.swift` |
| DTO | `PandaScore<Entity>DTO.swift` | `PandaScoreTournamentDTO.swift` |
| Mapper | `<Entity>Mapper.swift` | `TournamentMapper.swift` |
| Utility / helper | дескриптивно | `PrizepoolFormatter.swift` |

### Типы

```swift
// Структуры моделей — без префиксов
struct Tournament { ... }

// Протоколы — суффикс Protocol
protocol TournamentsServiceProtocol { ... }

// Имплементации протоколов — без префикса Default или Impl
final class TournamentsService: TournamentsServiceProtocol { ... }

// Enum для состояний — вложенные в Owner
extension TournamentsListViewModel {
    enum State {
        case loading
        case loaded([Tournament])
        case empty
        case error(UIError)
    }
}

// Builders / Mappers — enum со static func
enum TournamentMapper {
    static func map(_ dto: PandaScoreTournamentDTO) -> Tournament? { ... }
}

// Errors — enum с конкретными кейсами, не один Generic
enum TournamentsServiceError: Error {
    case noNetwork
    case rateLimited(retryAfter: TimeInterval)
    // ...
}
```

### Методы

```swift
// async-методы — без префикса async, без суффикса Async
func fetchTournaments(game: Game, segment: TournamentSegment) async throws -> [Tournament]

// Boolean-возвращающие — is/has/can
var isLive: Bool
func hasActiveStream() -> Bool

// Action handlers в ViewModel — onXxx
func onAppear() async
func onPullToRefresh() async
func onTapTournament(_ id: TournamentId)
```

### Переменные

```swift
// Свойства — lowerCamelCase
let tournamentId: TournamentId

// Константы внутри типа — статические
static let cacheTTL: TimeInterval = 60 * 10

// Глобальные константы — нет (всё в типе)

// Опциональные с дефолтом — лучше fallback на уровне доступа, не nil-coalescing в каждом use site
struct Match {
    let scheduledAt: Date?
    var displayScheduled: String { scheduledAt?.formatted() ?? "—" }
}
```

---

## Структура файла

Порядок секций сверху вниз:

```swift
//
//  TournamentsService.swift
//  GameSearch
//
//  Created by ... on ....
//

import Foundation
import Firebase            // Если нужны external

// MARK: - Protocol

protocol TournamentsServiceProtocol {
    func fetchTournaments(game: Game, segment: TournamentSegment) async throws -> [Tournament]
    func fetchTournament(id: TournamentId) async throws -> Tournament
}

// MARK: - Implementation

final class TournamentsService: TournamentsServiceProtocol {

    // MARK: - Dependencies

    private let api: PandaScoreAPIClient
    private let cache: CacheStore

    // MARK: - Init

    init(api: PandaScoreAPIClient, cache: CacheStore) {
        self.api = api
        self.cache = cache
    }

    // MARK: - Public

    func fetchTournaments(game: Game, segment: TournamentSegment) async throws -> [Tournament] {
        // ...
    }

    func fetchTournament(id: TournamentId) async throws -> Tournament {
        // ...
    }
}

// MARK: - Private

private extension TournamentsService {
    func cacheKey(for game: Game, segment: TournamentSegment) -> String {
        "tournaments:list:\(game.rawValue):\(segment.pandaScorePath)"
    }
}
```

---

## SwiftUI Views

### Структура

```swift
struct TournamentsListView: View {

    // MARK: - Observed

    @StateObject private var viewModel: TournamentsListViewModel
    @EnvironmentObject private var router: TournamentsRouter

    // MARK: - Init

    init(viewModel: TournamentsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            EAColor.background.ignoresSafeArea()
            content
        }
        .navigationTitle("Турниры")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(EAColor.background, for: .navigationBar)
        .task { await viewModel.onAppear() }
        .refreshable { await viewModel.onPullToRefresh() }
    }
}

// MARK: - Subviews

private extension TournamentsListView {
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .loading: skeleton
        case .loaded(let tournaments): list(tournaments)
        case .empty: emptyState
        case .error(let uiError): errorState(uiError)
        }
    }

    var skeleton: some View { TournamentsSkeletonList() }

    func list(_ tournaments: [Tournament]) -> some View { ... }

    var emptyState: some View { ... }

    func errorState(_ uiError: UIError) -> some View { ... }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TournamentsListView(viewModel: .preview)
    }
    .environmentObject(TournamentsRouter())
    .preferredColorScheme(.dark)
}
```

### Правила View

- **View — это `struct`**, не `class`.
- **Тело View — максимум 30-40 строк**. Длинные элементы — в `private extension` как computed-views.
- **`@ViewBuilder` для switch'ей**.
- **Никаких side-effects в body** (нет `print`, нет `viewModel.fetch()` — только декларация UI).
- **Preview — обязателен** для любого View. Если зависит от ViewModel — добавить `static var preview` через mock.

---

## ViewModel

```swift
@MainActor
final class TournamentsListViewModel: ObservableObject {

    // MARK: - State

    enum State {
        case loading
        case loaded([Tournament])
        case empty
        case error(UIError)
    }

    // MARK: - Published

    @Published private(set) var state: State = .loading
    @Published var selectedGame: Game = .cs2
    @Published var selectedSegment: TournamentSegment = .running

    // MARK: - Dependencies

    private let interactor: TournamentsListInteractorProtocol
    private let analytics: TournamentsAnalyticsReporting

    // MARK: - Init

    init(interactor: TournamentsListInteractorProtocol,
         analytics: TournamentsAnalyticsReporting = TournamentsAnalytics.shared) {
        self.interactor = interactor
        self.analytics = analytics
    }

    // MARK: - Intents

    func onAppear() async {
        analytics.report(.tournamentsTabOpened)
        await loadTournaments()
    }

    func onPullToRefresh() async {
        await loadTournaments(forceRefresh: true)
    }

    func onTapTournament(_ id: TournamentId, slug: String) {
        analytics.report(.tournamentOpened(id: id, slug: slug, fromScreen: "list"))
        // делегируем routing через router (получает через DI)
    }

    // MARK: - Private

    private func loadTournaments(forceRefresh: Bool = false) async {
        if case .loaded = state, !forceRefresh { state = .loading }
        // ...
    }
}
```

### Правила ViewModel

- **`@MainActor` на классе целиком.**
- **`@Published` поля имеют `private(set)`** где UI только читает.
- **State — вложенный enum**, не отдельный файл.
- **Intents — `onXxx()`**.
- **Никаких циклов retain** — закрытия захватывают `[weak self]` или `[self]` (новое async/await снижает риск, но всё ещё проверяем).

---

## Interactor

```swift
protocol TournamentsListInteractorProtocol {
    func fetchTournaments(game: Game, segment: TournamentSegment) async throws -> TournamentsListData
}

struct TournamentsListData {
    let tournaments: [Tournament]
    let liveMatches: [Match]
}

final class TournamentsListInteractor: TournamentsListInteractorProtocol {

    private let tournamentsService: TournamentsServiceProtocol
    private let matchesService: MatchesServiceProtocol

    init(tournamentsService: TournamentsServiceProtocol,
         matchesService: MatchesServiceProtocol) {
        self.tournamentsService = tournamentsService
        self.matchesService = matchesService
    }

    func fetchTournaments(game: Game, segment: TournamentSegment) async throws -> TournamentsListData {
        async let tournaments = tournamentsService.fetchTournaments(game: game, segment: segment)
        async let lives = matchesService.fetchLives(game: game)

        return TournamentsListData(
            tournaments: try await tournaments,
            liveMatches: try await lives
        )
    }
}
```

---

## Async patterns

### Параллельные запросы

```swift
async let a = serviceA.fetch()
async let b = serviceB.fetch()
let (resultA, resultB) = try await (a, b)
```

### Cancellation

Если ViewModel пересоздаётся или экран закрывается, активные Task должны отменяться:

```swift
@MainActor
final class FooViewModel: ObservableObject {
    private var loadingTask: Task<Void, Never>?

    func onAppear() {
        loadingTask?.cancel()
        loadingTask = Task {
            // ...
        }
    }

    func onDisappear() {
        loadingTask?.cancel()
    }
}
```

### Без блокировки main thread

Все сетевые / диск операции — async. Не использовать `DispatchQueue.global().async { ... DispatchQueue.main.async { ... } }`.

---

## Error handling

```swift
do {
    let result = try await service.fetch()
    state = .loaded(result)
} catch let error as TournamentsServiceError {
    state = .error(error.toUIError())
} catch is CancellationError {
    // тихо игнорируем — пользователь сменил экран
} catch {
    state = .error(.temporaryIssue)
}
```

**Не глотать молча ошибки** (`try?` без логирования — плохо). Если не критично — `try?` с явным комментарием почему.

---

## Логирование

- **Не использовать `print()`** в продакшн-коде.
- **`os_log`** для системных событий (debug сборки).
- **AppMetrica** для пользовательских событий.
- В debug-логах не утекают токены, ключи, persistent IDs.

---

## Импорты

```swift
import Foundation                  // первая
import SwiftUI                     // вторая
import Combine                     // если используется
import Firebase                    // third-party — далее
import AnalyticsModule             // local модули — последние
```

Не импортировать `import UIKit` без нужды (увеличивает время компиляции).

---

## Комментарии

- **Никаких redundant-комментариев** (`// Increment counter` — нет).
- **TODO с автором и датой** (`// TODO: [name 2026-05-25] поправить когда добавим LoL`).
- **`/// docs comments`** для public protocol-методов с неочевидным контрактом.
- **MARK: — для крупных секций**, не для каждого метода.

---

## Файловые операции

- Только через `FileManager.default`.
- Кэш — в `.cachesDirectory`. Persistent — в `.documentDirectory`.
- Никаких прямых путей вроде `"/var/mobile/..."`.

---

## URLSession

- Один shared `URLSession` через `PandaScoreAPIClient`.
- Timeout — 8 секунд для запросов.
- Retry policy — на уровне клиента, не в каждом сервисе.

---

## Тесты

- Файлы тестов — в `GameSearchTests/Tournaments/`.
- Имена — `<EntityUnderTest>Tests.swift` (например `TournamentMapperTests.swift`).
- Используем `XCTest` (не нативный Swift Testing, потому что проект на iOS 18 минимум, но проще единообразно).

Подробности — в `17-testing.md`.

---

## Git и коммиты

- **Не коммитим без явной просьбы пользователя** (правило проекта).
- **Не пушим в `main`** напрямую.
- **Messages — на английском**, короткие, в imperative mood: `Add TournamentsService with caching`.

---

## Что НЕ делать

- ❌ `weak var router: TournamentsRouter?` — Router передаём через @EnvironmentObject.
- ❌ `Singleton.shared` — DI через init.
- ❌ `String(format:)` для строк — используем интерполяцию.
- ❌ `if let x = x` — `if let x` (Swift 5.7+).
- ❌ `[String: Any]` в публичном API — определяем типизированные структуры.
- ❌ Закомментированный код — удаляем. Старый код есть в git.
- ❌ `Helpers.swift` / `Utils.swift` свалка — каждая утилита в своём файле.

---

_Last updated: 2026-05-25_
