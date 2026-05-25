# 08 — Modules & Files

Полная файловая структура модуля. Если в новом чате нужно создать новый файл — проверь, не существует ли он уже, и положи туда, где предписано.

---

## Корневая структура

```
GameSearch/
├── Services/
│   └── Tournaments/                        ← вся работа с PandaScore + кэш
│       ├── PandaScoreAPIClient.swift
│       ├── TournamentsService.swift
│       ├── MatchesService.swift
│       ├── TeamsService.swift
│       ├── PlayersService.swift
│       ├── FavoritesService.swift          ← Phase 1
│       ├── Cache/
│       │   ├── MemoryCache.swift
│       │   ├── DiskCache.swift
│       │   └── CacheStore.swift            ← фасад над L1+L2(+L3)
│       ├── Models/
│       │   ├── Domain/
│       │   │   ├── Tournament.swift
│       │   │   ├── Match.swift
│       │   │   ├── Team.swift
│       │   │   ├── Player.swift
│       │   │   ├── League.swift
│       │   │   ├── Serie.swift
│       │   │   ├── Stream.swift
│       │   │   ├── Standing.swift
│       │   │   ├── Bracket.swift
│       │   │   ├── Favorite.swift
│       │   │   └── Enums.swift             ← Game, Tier, MatchStatus, ...
│       │   └── DTO/
│       │       ├── PandaScoreTournamentDTO.swift
│       │       ├── PandaScoreMatchDTO.swift
│       │       ├── PandaScoreTeamDTO.swift
│       │       ├── PandaScorePlayerDTO.swift
│       │       ├── PandaScoreLeagueDTO.swift
│       │       ├── PandaScoreSerieDTO.swift
│       │       ├── PandaScoreStreamDTO.swift
│       │       ├── PandaScoreStandingDTO.swift
│       │       └── PandaScoreCommonDTO.swift  ← общие (videogame, paging)
│       ├── Mappers/
│       │   ├── TournamentMapper.swift
│       │   ├── MatchMapper.swift
│       │   ├── TeamMapper.swift
│       │   ├── PlayerMapper.swift
│       │   ├── LeagueMapper.swift
│       │   ├── SerieMapper.swift
│       │   ├── StreamMapper.swift
│       │   └── PrizepoolFormatter.swift
│       └── Errors/
│           └── TournamentsServiceError.swift
│
├── Modules/
│   └── Tournaments/                        ← вся UI-логика
│       ├── TournamentsRouter.swift         ← @ObservableObject с NavigationPath
│       ├── TournamentsRoute.swift          ← enum маршрутов
│       │
│       ├── TournamentsList/
│       │   ├── TournamentsListView.swift
│       │   ├── TournamentsListViewModel.swift
│       │   ├── TournamentsListInteractor.swift
│       │   ├── TournamentsListProtocols.swift
│       │   └── Views/
│       │       ├── TournamentCard.swift
│       │       ├── LiveMatchesStrip.swift
│       │       ├── LiveMatchChip.swift
│       │       ├── GameSegmentControl.swift
│       │       ├── TournamentsFilterSheet.swift   ← Phase 1
│       │       └── TournamentsSkeletonList.swift
│       │
│       ├── TournamentDetails/                ← Phase 1.B
│       │   ├── TournamentDetailsView.swift
│       │   ├── TournamentDetailsViewModel.swift
│       │   ├── TournamentDetailsInteractor.swift
│       │   ├── TournamentDetailsProtocols.swift  ← enum TournamentDetailsTab + state + interactor + VM протоколы
│       │   └── Views/
│       │       ├── TournamentHeaderView.swift
│       │       ├── TournamentTabPicker.swift     ← собственный 4-сегмент, НЕ через SwipeSegmentedView (см. ниже)
│       │       ├── MatchesTab.swift              ← внутри MatchRowView (private)
│       │       ├── StandingsTab.swift            ← внутри StandingRow + StandingsRowSkeleton (private)
│       │       ├── BracketsTab.swift             ← заглушка «Сетка скоро» (полная — Phase 4)
│       │       ├── ParticipantsTab.swift         ← внутри ParticipantsEmptyView (private)
│       │       ├── ParticipantTeamCard.swift
│       │       └── TournamentDetailsSkeleton.swift
│       │
│       ├── MatchDetails/
│       │   ├── MatchDetailsView.swift
│       │   ├── MatchDetailsViewModel.swift
│       │   ├── MatchDetailsInteractor.swift
│       │   ├── MatchDetailsProtocols.swift
│       │   └── Views/
│       │       ├── MatchHeaderView.swift
│       │       ├── MatchGamesList.swift
│       │       ├── GameMapRow.swift
│       │       ├── MatchRostersView.swift
│       │       ├── MatchStreamsList.swift
│       │       ├── StreamRow.swift
│       │       └── MatchDetailsSkeleton.swift
│       │
│       ├── TeamProfile/                    ← Phase 2
│       │   ├── TeamProfileView.swift
│       │   ├── TeamProfileViewModel.swift
│       │   └── Views/
│       │       ├── TeamHeaderView.swift
│       │       ├── TeamRosterList.swift
│       │       └── TeamRecentMatchesList.swift
│       │
│       ├── PlayerProfile/                  ← Phase 2
│       │   ├── PlayerProfileView.swift
│       │   ├── PlayerProfileViewModel.swift
│       │   └── Views/
│       │       └── PlayerHeaderView.swift
│       │
│       ├── Favorites/                      ← Phase 1
│       │   ├── FavoritesTabView.swift
│       │   ├── FavoritesViewModel.swift
│       │   └── Views/
│       │       └── FavoriteRow.swift
│       │
│       ├── Shared/                         ← переиспользуемые внутри модуля компоненты
│       │   ├── TierBadge.swift
│       │   ├── LiveBadge.swift             ← пульсирующий "● LIVE"
│       │   ├── TeamLogo.swift              ← AsyncImage с плейсхолдером
│       │   ├── GameAccentColor.swift
│       │   ├── DateRangeLabel.swift
│       │   ├── CountryFlag.swift
│       │   ├── PrizepoolLabel.swift
│       │   ├── ScoreView.swift             ← "16 : 14" с подсветкой winner
│       │   ├── MatchTimeFormatter.swift    ← Phase 1.B: relative time для матча (ru_RU)
│       │   ├── TournamentsEmptyStateView.swift ← Phase 1.A: универсальный empty/error
│       │   ├── TournamentsStrings.swift    ← Phase 1.A: микрокопи RU
│       │   ├── TournamentsAnalytics.swift  ← Phase 1.A: type-safe события AppMetrica
│       │   └── SpoilerWrapper.swift        ← Phase 3
│       │
│       └── TournamentsPlaceholderView.swift  ← ОСТАВИТЬ как error/empty state
│
├── Router/
│   ├── TabTag.swift                        ← уже есть .tournaments
│   ├── Deeplink.swift                      ← дополнить для турниров/матчей
│   └── Routes.swift                        ← добавить TournamentsRoute (см. ниже)
│
├── Factory/
│   ├── ScreenFactory.swift                 ← расширить методами make...
│   └── ScreenFactoryProtocol.swift         ← добавить associatedtypes
│
└── Resources/
    ├── Assets.xcassets/
    │   ├── cs.imageset/                    ← существующий, используем как иконку CS2
    │   └── dota2.imageset/                 ← существующий, используем как иконку Dota 2
    └── Localizable/
        └── tournaments.strings             ← Phase 4 локализация
```

---

## Изменения в существующих файлах

### `Router/Routes.swift`
Добавить enum для маршрутов турниров:

```swift
enum TournamentsRoute: Hashable {
    case tournamentDetails(TournamentId)
    case matchDetails(MatchId)
    case teamProfile(TeamId)             // Phase 2
    case playerProfile(PlayerId)         // Phase 2

    func hash(into hasher: inout Hasher) {
        switch self {
        case .tournamentDetails(let id): hasher.combine("t-\(id)")
        case .matchDetails(let id): hasher.combine("m-\(id)")
        case .teamProfile(let id): hasher.combine("team-\(id)")
        case .playerProfile(let id): hasher.combine("player-\(id)")
        }
    }
}
```

### `Router/Deeplink.swift`
Добавить разбор:
- `gamesearch://tournament/<id_or_slug>` → `.tournamentDetails`
- `gamesearch://match/<id>` → `.matchDetails`
- `gamesearch://team/<id>` → `.teamProfile` (Phase 2)
- `gamesearch://player/<id>` → `.playerProfile` (Phase 2)

### `Factory/ScreenFactoryProtocol.swift`
Добавить:

```swift
associatedtype TournamentsList: View
associatedtype TournamentDetails: View
associatedtype MatchDetails: View
associatedtype TeamProfile: View        // Phase 2
associatedtype PlayerProfile: View      // Phase 2

@MainActor func makeTournamentsListView() -> TournamentsList
@MainActor func makeTournamentDetailsView(id: TournamentId) -> TournamentDetails
@MainActor func makeMatchDetailsView(id: MatchId) -> MatchDetails
@MainActor func makeTeamProfileView(id: TeamId) -> TeamProfile
@MainActor func makePlayerProfileView(id: PlayerId) -> PlayerProfile
```

### `Factory/ScreenFactory.swift`
Реализовать с инжекцией shared instances `apiClient`, `cacheStore`, services.

### `GameSearchApp.swift`
Добавить:
```swift
.environmentObject(TournamentsRouter())
```

### `GameSearch/Services/Tournaments/PandaScoreTournamentsService.swift` (текущий placeholder)
- **НЕ удалять сразу.**
- Переименовать класс в `PlaceholderTournamentsService` или вынести логику в новый `TournamentsService`.
- Сейчас он отдаёт `[TournamentHeadline]` — это можно оставить для placeholder-карточек, но реальный `TournamentsService` будет возвращать `[Tournament]`.
- После MVP — удалить и убрать TODO-комментарий в коде.

### `GameSearch/Modules/Tournaments/TournamentsPlaceholderView.swift`
- **НЕ удалять.**
- Превратить в empty/error state, переиспользуемый компонент.
- Используется внутри `TournamentsListView` когда:
  - нет интернета и нет кэша,
  - фильтр вернул 0 турниров,
  - API недоступен.

---

## Зависимости между файлами (граф)

```
TournamentsListView
  └── TournamentsListViewModel
      └── TournamentsListInteractor
          ├── TournamentsService
          │   ├── PandaScoreAPIClient
          │   ├── CacheStore
          │   └── TournamentMapper
          └── MatchesService (для live strip)
              └── ...
```

Каждый Service зависит от:
- `PandaScoreAPIClient` (общий)
- `CacheStore` (общий)
- свои Mappers

Никаких circular dependencies.

---

## Решения по реюзу компонентов (Phase 1.B)

### `TournamentTabPicker` НЕ переиспользует `SwipeSegmentedView`

Изначально в этом документе и в `10-screens.md` предполагалось переиспользовать `Modules/Clubs/ClubDetailsView/Views/SectionPicker/SwipeSegmentedView.swift`. На практике этот компонент:

1. **Жёстко завязан на `DetailsSection`** (Clubs-специфичный enum с кейсами `.common` / `.specification`) и на `SectionPicker`. Обобщение требует параметризации обоих компонентов и аккуратной миграции `ClubDetailsView`.
2. **Использует `TabView(.page(indexDisplayMode: .never))`** для свайпов между табами — тяжелее по перфу с нашими 4 табами и lazy-загружаемой стандингс-вкладкой, и менее предсказуемо для unit-тестов.

Решение Phase 1.B: построить отдельный `TournamentTabPicker` в стиле уже существующего `TournamentSegmentControl` (Phase 1.A) — единый визуальный язык внутри модуля, минимальная поверхность для багов. Если в Phase 4 (Polish) потребуется swipe-between-tabs, чистый рефакторинг — generic-параметризация `SwipeSegmentedView<Tag: Hashable & Identifiable>` отдельным тикетом.

---

## Что НЕ создавать (распространённые ошибки агентов)

- ❌ **Не создавать отдельный `NetworkManager` / `APIManager` singleton.** Один `PandaScoreAPIClient` через DI — достаточно.
- ❌ **Не вводить Combine `@Published` с pipeline'ами `.sink`.** Async/await + `@MainActor`.
- ❌ **Не создавать `Constants.swift` со всеми строками.** Локализация — отдельная история, см. `12-microcopy-ru.md`.
- ❌ **Не дублировать `Color.csOrange` / `Color.dotaRed`.** Используем `EAColor.csColor` / `EAColor.dotaColor`.
- ❌ **Не создавать свои навигационные `NavigationLink(destination:)`.** Используем `TournamentsRouter` с `NavigationStack` + `navigationDestination(for:)`.
- ❌ **Не создавать `TournamentsCoordinator` поверх Router'а.** Router в нашем паттерне = координатор.
- ❌ **Не выносить DTO в публичный API сервиса.** Сервис отдаёт только Domain.
- ❌ **Не создавать `BaseViewModel` / `BaseInteractor`.** В Swift нет нужды в abstract base classes для подобного.

---

## Naming conventions

| Что | Шаблон | Пример |
|---|---|---|
| View | `<Feature>View` | `TournamentsListView` |
| ViewModel | `<Feature>ViewModel` | `TournamentsListViewModel` |
| Interactor | `<Feature>Interactor` | `TournamentsListInteractor` |
| Protocol-набор для модуля | `<Feature>Protocols.swift` | `TournamentsListProtocols.swift` |
| Service | `<Entity>Service` | `TournamentsService` |
| Service Protocol | `<Entity>ServiceProtocol` | `TournamentsServiceProtocol` |
| DTO | `PandaScore<Entity>DTO` | `PandaScoreTournamentDTO` |
| Mapper | `<Entity>Mapper` (enum со static func map) | `TournamentMapper` |
| Domain model | без префикса | `Tournament` |
| Маленькие View-компоненты | дескриптивно | `LiveMatchChip`, `TierBadge` |

---

_Last updated: 2026-05-25 (Phase 1.B — добавлен `TournamentDetails/` с реальной реализацией, `Shared/MatchTimeFormatter.swift`, ADR-эквивалент про `TournamentTabPicker`)_
