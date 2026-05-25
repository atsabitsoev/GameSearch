# 05 — Architecture

Общая архитектура модуля «Турниры». Слои, потоки данных, ответственности.

---

## Принципы

1. **Соответствие существующему паттерну проекта** — VIPER-подобная схема (`Service → Interactor → ViewModel → View`) с `Router` для навигации и `ScreenFactory` для DI. Не вводим TCA, Redux, RxSwift и т.п.
2. **Layered architecture** — каждый слой видит только слой ниже. UI не знает про сеть, сеть не знает про UI.
3. **Domain-models отдельно от DTO** — `Tournament` (domain) и `PandaScoreTournament` (DTO) — разные типы. Это позволит безболезненно сменить источник данных или добавить кэш.
4. **Async/await везде** — без Combine для сетевых запросов, без `Result` callbacks. SwiftUI + async тестируется проще.
5. **Без singletons** — все зависимости через инициализаторы. `ScreenFactory` — единственное место для DI.

---

## Диаграмма слоёв

```
┌───────────────────────────────────────────────────────────────┐
│                          View (SwiftUI)                       │
│  TournamentsListView · TournamentDetailsView · MatchDetailsView│
└──────────────────────────────┬────────────────────────────────┘
                               │ @State / @StateObject
                               ▼
┌───────────────────────────────────────────────────────────────┐
│                     ViewModel (ObservableObject)              │
│  TournamentsListViewModel · TournamentDetailsViewModel · ...  │
│  - @Published state                                           │
│  - intent methods (onAppear, onRefresh, onTap, ...)           │
└──────────────────────────────┬────────────────────────────────┘
                               │ протоколы
                               ▼
┌───────────────────────────────────────────────────────────────┐
│                       Interactor                              │
│  TournamentsListInteractor · TournamentDetailsInteractor      │
│  - бизнес-логика (фильтры, агрегация, сортировка)             │
│  - комбинирует несколько Services                             │
└──────────────────────────────┬────────────────────────────────┘
                               │ протоколы
                               ▼
┌───────────────────────────────────────────────────────────────┐
│                       Service (Domain)                        │
│  TournamentsService · MatchesService · TeamsService · ...     │
│  - возвращает Domain Models                                   │
│  - инкапсулирует кэш + сеть                                   │
└──────────────────────────────┬────────────────────────────────┘
                               │
       ┌───────────────────────┼────────────────────────┐
       ▼                       ▼                        ▼
┌─────────────┐       ┌─────────────────┐      ┌────────────────┐
│ CacheStore  │       │ PandaScore      │      │ FirestoreProxy │
│ (L1 memory  │       │ APIClient       │      │ (L3, Phase 1+) │
│  + L2 disk) │       │ (HTTP, retry,   │      │                │
│             │       │  rate-limit)    │      │                │
└─────────────┘       └────────┬────────┘      └───────┬────────┘
                               │                       │
                               ▼                       ▼
                       PandaScore REST          Firestore (Firebase)
                       api.pandascore.co
```

---

## Ответственности слоёв

### View
- Только декларативная композиция UI.
- Биндится на `@StateObject` ViewModel.
- Никакой бизнес-логики, никаких `if status == .running { fetch... }`.
- Принимает только данные для отрисовки, шлёт intents наверх.

### ViewModel
- `@Published` state для UI.
- Intent-методы (`onAppear()`, `onPullToRefresh()`, `onTapTournament(_:)`, ...).
- Делегирует работу в Interactor.
- **На @MainActor** (не отдельный @MainActor на каждое поле).

```swift
@MainActor
final class TournamentsListViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    @Published var selectedGame: Game = .cs2
    @Published var selectedSegment: TournamentSegment = .running

    private let interactor: TournamentsListInteractorProtocol

    init(interactor: TournamentsListInteractorProtocol) { ... }

    func onAppear() async { ... }
    func onPullToRefresh() async { ... }
    func onTapTournament(_ id: TournamentId) { ... }
}
```

### Interactor
- Бизнес-логика, которая может быть unit-тестирована в изоляции.
- Комбинирует данные из нескольких Services.
- Применяет фильтры, сортировку, агрегацию (например, «сгруппировать матчи по стадиям»).
- Не знает про SwiftUI и не имеет @Published полей.

### Service
- Возвращает **доменные модели** (`Tournament`, `Match`, ...).
- Инкапсулирует логику кэширования: сначала проверяет `CacheStore`, при miss идёт в `PandaScoreAPIClient`, сохраняет в кэш.
- Знает TTL для конкретного типа данных.
- Может иметь несколько источников (Phase 1+: сначала FirestoreProxy, потом PandaScoreAPIClient).

### PandaScoreAPIClient (Network)
- Generic HTTP-клиент с retry, rate-limiting, error mapping.
- Возвращает DTO (`PandaScoreTournamentDTO`, ...).
- Не знает про доменные модели.
- Один экземпляр на приложение (передаётся через DI).

### Mapper
- Чистые функции `DTO → Domain`.
- Без побочных эффектов.
- Тестируются на snapshot-JSON.

### CacheStore
- L1: `NSCache<NSString, CachedEntry>` для горячих данных в текущей сессии.
- L2: `FileManager`-based JSON-кэш в `Library/Caches/Tournaments/` для переживания рестарта.
- L3 (Phase 1+): Firestore-прокси — общий кэш для всех пользователей.

### Router
- `TournamentsRouter: ObservableObject` (по аналогии с `ClubsRouter`).
- Управляет `NavigationStack` и push/pop.
- Не делает сетевых запросов.

### ScreenFactory
- Единственное место создания экранов с инжекцией зависимостей.
- Расширяем `ScreenFactoryProtocol` методами `makeTournamentsListView`, `makeTournamentDetailsView`, `makeMatchDetailsView`, ...

---

## Потоки данных

### Сценарий: открытие списка турниров

```
User taps tab "Турниры"
   │
   ▼
RootView → ScreenFactory.makeTournamentsListView()
   │
   ▼
TournamentsListView.onAppear → viewModel.onAppear()
   │
   ▼
ViewModel sets state = .loading, calls interactor.fetchTournaments(game: .cs2, segment: .running)
   │
   ▼
Interactor calls tournamentsService.fetchTournaments(game: .cs2, segment: .running)
   │
   ▼
Service:
  1. CacheStore.read(key: "tournaments:csgo:running") → if hit & fresh → return
  2. else PandaScoreAPIClient.get(path: "/csgo/tournaments/running", ...)
  3. mapper(dto) → [Tournament]
  4. CacheStore.write(key: ..., value: [Tournament], ttl: 5min)
  5. return [Tournament]
   │
   ▼
Interactor groups/sorts as needed, returns
   │
   ▼
ViewModel sets state = .loaded(tournaments)
   │
   ▼
SwiftUI re-renders List with TournamentCard rows
```

### Сценарий: тап на турнир

```
User taps card
   │
   ▼
TournamentCard onTap → viewModel.onTapTournament(id)
   │
   ▼
ViewModel asks router: router.push(.tournamentDetails(id))
   │
   ▼
NavigationStack push → ScreenFactory.makeTournamentDetailsView(id) → TournamentDetailsView
   │
   ▼
[same flow as list, но для одного турнира]
```

### Сценарий: тап «Смотреть стрим»

```
User taps stream row
   │
   ▼
MatchDetailsView → viewModel.onTapStream(stream)
   │
   ▼
ViewModel resolves URL:
  - twitch.tv/<channel> → twitch://stream/<channel> (with universal link fallback)
  - youtube.com/watch?v=... → youtube://...
  - other → safari
   │
   ▼
UIApplication.shared.open(url)
   │
   ▼
AppMetrica event "stream_opened"
```

---

## Error Handling

Все ошибки нормализуются в один enum на уровне Service:

```swift
enum TournamentsServiceError: Error {
    case noNetwork              // URLError.notConnectedToInternet
    case rateLimited(retryAfter: TimeInterval)
    case serverError(status: Int)
    case decoding(Error)
    case unauthorized           // токен невалидный / отсутствует
    case unknown(Error)
}
```

ViewModel преобразует их в state:

```swift
enum State {
    case loading
    case loaded([Tournament])
    case empty                  // запрос успешен, но 0 элементов
    case error(UIError)         // что показать пользователю
}

enum UIError {
    case noInternet
    case temporaryIssue         // 5xx / rate limit / unknown
    case emptyFilter            // частный случай для empty с фильтром
}
```

В UI — простые empty/error views с кнопкой «Повторить». Никаких alert popup.

---

## Конкурентность

- Все async-методы — `Task`-based.
- `ViewModel` на `@MainActor` чтобы безопасно мутировать `@Published`.
- `Service` и ниже — без actor (потокобезопасны через async и отсутствие shared mutable state).
- `CacheStore` — внутренне через `actor`, чтобы безопасно мутировать L1/L2.

---

## Dependency Injection

Через инициализаторы. `ScreenFactory` собирает граф:

```swift
final class ScreenFactory: ScreenFactoryProtocol {
    private let apiClient: PandaScoreAPIClient
    private let cacheStore: CacheStore
    private let tournamentsService: TournamentsServiceProtocol
    private let matchesService: MatchesServiceProtocol

    init() {
        self.apiClient = PandaScoreAPIClient()
        self.cacheStore = CacheStore()
        self.tournamentsService = TournamentsService(api: apiClient, cache: cacheStore)
        self.matchesService = MatchesService(api: apiClient, cache: cacheStore)
    }

    @MainActor
    func makeTournamentsListView() -> some View {
        let interactor = TournamentsListInteractor(
            tournamentsService: tournamentsService,
            matchesService: matchesService
        )
        let viewModel = TournamentsListViewModel(interactor: interactor)
        return TournamentsListView(viewModel: viewModel)
    }
    // ...
}
```

В тестах подменяем `TournamentsServiceProtocol` на mock.

---

## Расширяемость

Архитектура должна позволять без боли:

1. **Добавить новую игру**: новый case в `Game` enum + `prefix` маппинг. UI работает as-is.
2. **Добавить новый источник данных**: новая имплементация `TournamentsServiceProtocol`. Например, `LiquipediaTournamentsService` в Future.
3. **Включить bypass кэша для отладки**: флаг в `CacheStore.init(bypass: true)`.
4. **Перейти на Firestore-прокси для real-time**: добавить `FirestoreTournamentsSource` и использовать его как L3 в `CacheStore`.

---

_Last updated: 2026-05-25_
