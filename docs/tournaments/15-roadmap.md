# 15 — Roadmap

План разработки модуля «Турниры» по фазам с конкретными тикетами. Это **живой документ** — отмечайте чек-боксы по мере прогресса.

Оценки времени — для одного разработчика-человека в фокусе. Для AI-агента — это скорее последовательность задач, без точных сроков.

---

## Phase 0 — Foundation (инфраструктура модуля)

**Цель**: подготовить слой данных и каркас экранов, не меняя пока поведение для пользователя.

**Estimated**: 2-3 дня.

### Задачи

- [x] **0.1** Создать `Services/Tournaments/PandaScoreAPIClient.swift` — generic HTTP-клиент с retry, error mapping, поддержкой rate-limit.
- [x] **0.2** Создать `Services/Tournaments/Cache/MemoryCache.swift` (L1, NSCache actor).
- [x] **0.3** Создать `Services/Tournaments/Cache/DiskCache.swift` (L2, FileManager actor).
- [x] **0.4** Создать `Services/Tournaments/Cache/CacheStore.swift` — фасад над L1+L2.
- [x] **0.5** Создать `Services/Tournaments/Models/Domain/Enums.swift` — Game, Tier, TournamentSegment, MatchStatus, MatchType, StreamPlatform, WinnerType.
- [x] **0.6** Создать domain-модели: Tournament, Match, Team, Player, League, Serie, Stream, Standing, Bracket, MatchResult, Opponent, Match.PlayedGame, TournamentParticipant, Prizepool. (`Models/Domain/`)
- [x] **0.7** Создать DTO-модели: PandaScoreTournamentDTO, PandaScoreMatchDTO, PandaScoreTeamDTO, PandaScorePlayerDTO, PandaScoreLeagueDTO, PandaScoreSerieDTO, PandaScoreStreamDTO, PandaScoreStandingDTO, PandaScoreCommonDTO. (`Models/DTO/`)
- [x] **0.8** Создать Mappers: TournamentMapper, MatchMapper, TeamMapper, PlayerMapper, StreamMapper, LeagueMapper, SerieMapper, StandingMapper, PrizepoolFormatter.
- [x] **0.9** Создать `TournamentsServiceError.swift` с unified ошибками.
- [x] **0.10** Создать `TournamentsService` со всеми методами (fetchTournaments, fetchTournamentDetails, fetchStandings, fetchBrackets), используя API client + cache.
- [x] **0.11** Создать `MatchesService` (fetchMatches, fetchMatchDetails, fetchLives).
- [x] **0.12** Создать `Modules/Tournaments/TournamentsRouter.swift` (ObservableObject с NavigationPath).
- [x] **0.13** Создать `Modules/Tournaments/TournamentsRoute.swift` (enum маршрутов).
- [x] **0.14** Расширить `Routes.swift` — добавить TournamentsRoute. **Реализовано как отдельный файл** `Modules/Tournaments/TournamentsRoute.swift` (по `08-modules-and-files.md`).
- [x] **0.15** Расширить `Router/Deeplink.swift` — кейсы для tournaments/tournament/match. Парсер дополнительно поддерживает custom-scheme URLs (`gamesearch://...`) и universal links (`https://gamesearch.app/...`). Минимальная правка `RootView.handleUrl` — добавлен `default: return` чтобы switch остался exhaustive (реальное роутинг-поведение в Phase 1).
- [x] **0.16** Расширить `Factory/ScreenFactoryProtocol.swift` — associatedtypes и методы (`TournamentsList`, `TournamentDetails`, `MatchDetails`).
- [x] **0.17** Расширить `Factory/ScreenFactory.swift` — реализация с инжекцией shared services (`PandaScoreAPIClient`, `CacheStore`, `TournamentsService`, `MatchesService`). Новые make-методы возвращают placeholder-вьюхи; реальные View подключим в Phase 1.
- [x] **0.18** Подключить `TournamentsRouter` в `GameSearchApp.swift` через `.environmentObject(...)`.
- [x] **0.19** Assets для иконок игр. **Используем существующие** `cs.imageset` и `dota2.imageset` из `Assets.xcassets` (`Game.iconName` → `"cs"` / `"dota2"`). Документация (`06-data-models.md`, `08-modules-and-files.md`) обновлена под фактическое именование.

### Дополнительные задачи Phase 0 (вне исходного списка, но необходимые для DoD)

- [x] **0.20** Разрешить конфликт имён: переименован старый `TournamentsServiceProtocol` → `PlaceholderTournamentsServiceProtocol` (placeholder продолжает работать как раньше).
- [x] **0.21** Добавлен `GameSearchTests` target в `project.pbxproj` и `GameSearch.xcscheme` (PBXNativeTarget, PBXFileSystemSynchronizedRootGroup для folder-sync, build phases, XCConfigurationList, dependency, scheme TestableReference).
- [x] **0.22** Покрытие тестами (48 тестов, все проходят): mappers (Tournament, Match, Team, Player), Prizepool formatter, MemoryCache, DiskCache, TournamentsService, MatchesService, Deeplink parser + JSON-фикстуры PandaScore + `MockPandaScoreAPIClient`.

### Definition of Done для Phase 0

- [x] Проект собирается через `xcode-tools.BuildProject` без ошибок.
- [x] Service-слой покрыт unit-тестами (через protocol-based mock `MockPandaScoreAPIClient`). 48/48 тестов проходят.
- [x] Старый `PandaScoreTournamentsService` и `TournamentsPlaceholderView` работают как раньше (placeholder UI рендерится, таб «Турниры» доступен, поведение не изменилось).

---

## Phase 1 — MVP (UI экраны)

**Цель**: показать пользователю реальные данные турниров и матчей.

**Estimated**: 7-10 дней.

### Задачи

#### 1.A. Список турниров

- [x] **1.1** Создать `Modules/Tournaments/Shared/TierBadge.swift`.
- [x] **1.2** Создать `Modules/Tournaments/Shared/LiveBadge.swift` (с пульсацией).
- [x] **1.3** Создать `Modules/Tournaments/Shared/TeamLogo.swift` (с fallback gradient + initials, через `CachedAsyncImage`).
- [x] **1.4** Создать `Modules/Tournaments/Shared/DateRangeLabel.swift` (+ `DateRangeFormatter` с `ru_RU` локалью).
- [x] **1.5** Создать `Modules/Tournaments/Shared/CountryFlag.swift` (эмодзи из ISO 3166-1 alpha-2).
- [x] **1.6** Создать `Modules/Tournaments/Shared/PrizepoolLabel.swift` (поверх существующего `PrizepoolFormatter`).
- [x] **1.7** Создать `Modules/Tournaments/Shared/ScoreView.swift` (с подсветкой победителя через `EAColor.yellow`).
- [x] **1.8** Создать `Modules/Tournaments/TournamentsList/Views/GameSegmentControl.swift`.
- [x] **1.9** Создать `Modules/Tournaments/TournamentsList/Views/TournamentCard.swift`.
- [x] **1.10** Создать `Modules/Tournaments/TournamentsList/Views/LiveMatchChip.swift`.
- [x] **1.11** Создать `Modules/Tournaments/TournamentsList/Views/LiveMatchesStrip.swift` (скрывается при пустом списке).
- [x] **1.12** Создать `Modules/Tournaments/TournamentsList/Views/TournamentsSkeletonList.swift` (+ shimmer).
- [x] **1.13** Создать `TournamentsListProtocols.swift`, `TournamentsListInteractor.swift`, `TournamentsListViewModel.swift`, `TournamentsListView.swift`.
- [x] **1.14** Подключить пагинацию (infinity scroll). `TournamentsService.fetchTournamentsPage(page:pageSize:)` (page 1 сохраняет старый cache key — Phase 0 тесты не сломаны).
- [x] **1.15** Подключить pull-to-refresh (`.refreshable {}` + `CacheStore.invalidate(prefix:)`).
- [x] **1.16** Подключить empty/error states. Реализовано через новый универсальный компонент `Modules/Tournaments/Shared/TournamentsEmptyStateView.swift` с 5 видами kind (`emptyRunning/Upcoming/Past`, `errorNoInternet`, `errorTemporary`). Старый `TournamentsPlaceholderView` сохранён как было до удаления PandaScoreTournamentsService.
- [x] **1.17** Заменить `ScreenFactory.makeTournamentsView()` с placeholder на `TournamentsListView`. Также подключён `TournamentsRouter` в `RootView` через `NavigationStack(path:)` + `.navigationDestination(for: TournamentsRoute.self)`. Detail-экраны пока через `TournamentsPhasePlaceholder` — реальные подключим в 1.B/1.C.
- [x] **1.18** Аналитика: `tournaments_tab_opened`, `tournaments_segment_switched`, `tournaments_game_switched`, `tournaments_pulled_to_refresh`. Type-safe wrapper `TournamentsAnalytics` + enum `TournamentsAnalyticsEvent` (Shared/). Дополнительно: `tournaments_list_scrolled_to_bottom`, `tournament_opened`, `live_strip_shown`, `live_strip_chip_tapped`, `match_opened`, `tournaments_error_shown`, `tournaments_error_retry_tapped`.

### Дополнительные задачи Phase 1.A (вне исходного списка, но необходимые для DoD)

- [x] **1.A.1** Создан `Shared/TournamentsStrings.swift` — единый источник всех русских строк модуля (Phase 4 перейдут в `Localizable.strings`).
- [x] **1.A.2** Создан `Shared/TournamentsAnalytics.swift` — type-safe enum `TournamentsAnalyticsEvent` + `TournamentsAnalyticsReporting` для DI в `ViewModel`.
- [x] **1.A.3** Создан `Shared/GameAccentColor.swift` — централизованная маппинг `Game → Color`.
- [x] **1.A.4** Создан `TournamentsList/Views/TournamentSegmentControl.swift` — 3-сегмент контрол (Сейчас/Скоро/Прошедшие), не было выделено в roadmap, но требуется wireframes из `10-screens.md`.
- [x] **1.A.5** В `Info.plist` зарегистрирован URL scheme `gamesearch` для deeplinks. `RootView.handleUrl` теперь обрабатывает `gamesearch://tournaments`, `gamesearch://tournament/<id_or_slug>`, `gamesearch://match/<id>` (последние два пушат в `tournamentsRouter`). DoD требование «deeplinks работают (тест через simctl openurl)» — проверено в симуляторе.
- [x] **1.A.6** `ScreenFactoryProtocol.makeTournamentsView()` помечен `@MainActor` чтобы устранить Swift 6 warning о пересечении main actor isolation границ.
- [x] **1.A.7** Группировка стадий турнира по серии на клиенте. PandaScore возвращает каждую стадию (Group A / Group B / Playoffs) как отдельный объект `Tournament`, и `prizepool` чаще всего привязан только к Playoffs. Без группировки в списке появлялись дубликаты заголовков и «пустые» призовые. Добавлена доменная модель `Services/Tournaments/Models/Domain/TournamentSeriesGroup.swift` с фабрикой `makeGroups(from:)` (группирует по `serie.id`, сортирует стадии по `begin_at` с tie-breaker по `name`/`id`), агрегирует `beginAt`/`endAt` (min/max) и `prizepool` (первый non-nil). `TournamentsListState.loaded` теперь хранит `[TournamentSeriesGroup]` вместо `[Tournament]`; `TournamentCard` принимает группу и рендерит подзаголовок `"Group A · Group B · Playoffs"`. Навигация использует context-aware метод `representativeStage(for: segment)`: для `running` — live стадия → следующая по времени, для `upcoming` — первая стадия (Stage 1 / Group A), для `past` — последняя (Playoffs). Также добавлен computed-helper `Tournament.displayListTitle` — fallback на `"<League> <year>"` когда у серии пустое `name` (PandaScore-кейс «CS Asia Championships 2026»).

#### 1.B. Детали турнира

- [x] **1.19** Создать `Modules/Tournaments/TournamentDetails/Views/TournamentHeaderView.swift`. Лого лиги (через `CachedAsyncImage` с trophy-placeholder), название лиги/серии/стадии, диапазон дат (через `DateRangeLabel`), live-бейдж (если стадия live), флаг страны + ISO-код, `TierBadge`, `PrizepoolLabel`. Радиус карточки 16, цвет фона `secondaryBackground`.
- [x] **1.20** Создать `Modules/Tournaments/TournamentDetails/Views/TournamentTabPicker.swift`. **Отказ от `SwipeSegmentedView`**: существующий компонент жёстко завязан на `DetailsSection` (Clubs) и `TabView(.page)`. Сделан horizontally-scrollable 4-сегмент контрол в стиле `TournamentSegmentControl` (Phase 1.A) — единый визуальный язык внутри модуля. Если в Phase 4 потребуется swipe-between-tabs, чистый рефакторинг — generic-параметризация `SwipeSegmentedView` (отдельный тикет).
- [x] **1.21** Создать `MatchesTab.swift` + локальный `MatchRowView`. Группировка матчей одной стадии в один список с сортировкой: live → upcoming (`scheduledAt` asc) → finished (`endAt` desc). Подсветка победителя через `EAColor.yellow`. Статусы canceled/postponed — pill-бейдж рядом с "vs". Empty state переиспользует `TournamentsEmptyStateView(.emptyUpcoming)`.
- [x] **1.22** Создать `StandingsTab.swift` (`StandingsTab.State` управляется отдельным `standingsState` в VM, lazy-load при первом выборе таба). Header `# / Команда / В / П / Очки`, rank подсвечен `yellow` (1) → `purpleAccent` (2-3) → `textSecondary`. Skeleton-список из 6 строк.
- [x] **1.23** Создать `ParticipantsTab.swift` + `ParticipantTeamCard.swift`. Карточка команды: `TeamLogo(size:36)` + имя + location, секция "Состав" со списком игроков (`CountryFlag` + nickname + role). Empty state для команд (если `participants == nil/[]`) — кастомный inline-компонент с иконкой `person.3.fill`.
- [x] **1.24** Создать заглушку `BracketsTab.swift` с текстом «Сетка скоро появится» (`square.grid.3x2` иконка + микрокопи из `TournamentsStrings`).
- [x] **1.25** Создать `TournamentDetailsSkeleton.swift`. Композиция: header-skeleton (лого + 4 строки + бейджи + призовой) → tab-picker stub → 4 match-row stubs. Использует `SkeletonRectangle` из Phase 1.A.
- [x] **1.26** Создать `TournamentDetailsProtocols.swift` (enum `TournamentDetailsTab`, `TournamentDetailsInteractorProtocol`, `TournamentDetailsState`, `TournamentDetailsStandingsState`, `TournamentDetailsViewModelProtocol`), `TournamentDetailsInteractor.swift` (proxy к `TournamentsService.fetchTournamentDetails/fetchStandings` + cache invalidation), `TournamentDetailsViewModel.swift` (генерационные счётчики для отмены stale-fetch, pushRoute-closure для роутинга без EnvironmentObject, lazy-load standings), `TournamentDetailsView.swift` (composition + ShareLink + toolbar + refreshable). Подключён в `Factory/ScreenFactory.makeTournamentDetailsView(idOrSlug:)`.
- [x] **1.27** Подключить deeplink `gamesearch://tournament/<id_or_slug>`. Уже работало с Phase 1.A (`RootView.handleUrl`) — теперь пушит реальный `TournamentDetailsView` вместо placeholder.
- [x] **1.28** Подключить share-кнопку через `ShareLink`. URL = `gamesearch://tournament/<slug>` (fallback `id` если slug пустой). Кнопка показывается только в `.loaded` state. `simultaneousGesture` шлёт `tournamentShared` analytics при первом tap (до открытия системного sheet).
- [x] **1.29** Аналитика: `tournament_opened` (с `from_screen=list|deeplink`), `tournament_tab_switched` (с `tab=matches|standings|brackets|participants`), `tournament_shared` (с `tournament_id`, `tournament_slug`). Также `match_opened` (with `from_screen=tournament`), `tournaments_error_shown`/`retry_tapped` (screen=details). Новый screen enum case `.tournament` для from_screen матча.

### Дополнительные задачи Phase 1.B (вне исходного списка)

- [x] **1.B.1** Расширен `Shared/TournamentsStrings.swift` строками деталей турнира (`tournamentDetailsNavTitleFallback`, `tournamentTab*`, `tournamentPrize/ShareLabel`, `tournamentBracketsComingSoon*`, `standingsCol*`, `participants*`, `matchesEmpty*`, `time*`, `matchStatusFinished/Canceled/Postponed`).
- [x] **1.B.2** Расширен `Shared/TournamentsAnalytics.swift` событиями `tournamentTabSwitched(id:tab:)` и `tournamentShared(id:slug:)`, добавлен enum `TournamentTab`, добавлен screen-case `.tournament` для `matchOpened.fromScreen`.
- [x] **1.B.3** Создан `Shared/MatchTimeFormatter.swift` — единый форматтер времени матча: `upcoming` (сегодня/завтра/d MMM, HH:mm), `finished` (вчера/сегодня/d MMM в HH:mm), `clock` (HH:mm). Использует `ru_RU` локаль. Будет переиспользован в Phase 1.C (`MatchDetailsView`) и Phase 3 (`TeamRecentMatchesList`).

### Bugfix-итерация после Phase 1.B (по результатам Proxyman-разбора)

- [x] **1.B.bug1** Inline-матчи в ответе `GET /tournaments/<idOrSlug>` приходят без `opponents`, `results`, `league_id`, `videogame` — `MatchMapper` корректно их отбрасывал и `MatchesTab` оставался пустым. **Решение**: добавлен `MatchesService.fetchTournamentMatches(tournamentId:)` поверх endpoint `GET /matches?filter[tournament_id]=<id>&page[size]=100&sort=begin_at` (полная shape матчей). `TournamentDetailsInteractor` теперь принимает `MatchesService` и проксирует к нему. В VM появился `matchesState: TournamentDetailsMatchesState` (idle/loading/loaded/empty/error). После успешной загрузки `tournament`, VM сразу же кикает `loadMatches(tournamentId:)`. `MatchesTab` принимает `matchesState` + `stageName` + `onRetry` вместо чтения `tournament.matches`. Pull-to-refresh инвалидирует и tournament-detail, и matches кэш. Cache TTL: 60s для live-сетов, 1h для статичных. Добавлены тесты `test_fetchTournamentMatches_*` в `MatchesServiceTests`.
- [x] **1.B.bug2** PandaScore возвращает `[{rank, team, last_match}]` для playoff standings без `wins`/`losses`/`points`. UI рендерил "0/0/—" что выглядело как баг. **Решение**: `Standing.wins`/`Standing.losses` сделаны `Int?`. `StandingMapper` больше не превращает nil в 0. `StandingsTab` через новый struct `StandingsColumnLayout(standings:)` детектит какие колонки реально содержат данные и скрывает пустые — таблица деградирует до минимальной формы `# | Команда`. Тесты: `StandingMapperTests` + `StandingsColumnLayoutTests`.
- [x] **1.B.bug2.v2** Исследование через Proxyman+curl показало: PandaScore **на самом деле** возвращает полную shape (`wins`, `losses`, `ties`, `total`, `game_wins`, `game_losses`, `game_ties`) — но только для **group/Swiss** стадий, не для playoff bracket (changelog 2.57.0 «added the team's game wins, losses and ties to **group** tournament standings»). Astana 2026 Playoffs (тестировали) — это bracket, поэтому полей нет. Astana 2026 **Group Stage** (отдельный tournament id 20902) отдаёт всю shape. **Решение**: расширены `PandaScoreStandingDTO` и `Standing` полями `total`, `gameWins`, `gameLosses`, `gameTies`. `StandingsTab` теперь показывает 5 опциональных колонок: «В», «П», «Игр» (= total), «Карты» (= "gameWins-gameLosses"), «Очки» (legacy points для других игр). Все колонки скрываются индивидуально через `StandingsColumnLayout`. Подтверждено на симуляторе: Astana Group Stage показывает 16 команд с реальными цифрами (9z: 3-0, 6-2; FURIA: 3-1, 7-3), Playoffs корректно деградирует до `# | Команда`. Добавлены тесты для group-stage и legacy-points сценариев.
- [x] **1.B.bug2.v3** Из UI нельзя было попасть на Group Stage — навигация из списка автоматически открывает «representative stage» (Playoffs для past, Group для upcoming), и Group Stage с полной таблицей был доступен только через прямой deeplink. **Решение**: добавлен `TournamentStagePicker` — горизонтально-скроллируемый picker сиблингов-стадий той же серии. Появляется ТОЛЬКО если у серии больше 1 стадии. Лейблы из `tournament.name`: `Group Stage · Playoffs` / `Group A · Group B · Playoffs`. Тап → reload tournament + matches + standings (для новой стадии), share URL автоматически обновляется. Стадии подгружаются через новый `TournamentsService.fetchSeriesTournaments(serieId:)` (`GET /series/<id>/tournaments`), TTL 1ч, кэш инвалидируется на pull-to-refresh. Новые тесты: `test_fetchSeriesTournaments_*` (2 теста). Новое событие аналитики `tournament_stage_switched(from_stage_id, to_stage_id, serie_id)`. Подтверждено на симуляторе: открываем Astana Playoffs → видим picker → тап Group Stage → reload → видим Group Stage с полной таблицей (9z: 3-0, 6-2 и т.д.).

#### 1.C. Детали матча

- [x] **1.30** Создать `Modules/Tournaments/MatchDetails/Views/MatchHeaderView.swift`. Caption "League · Stage" (из tournamentContext), три-колончатый блок [Logo+Team] [BoX/LIVE/score|время] [Logo+Team], footer-строка с временем. Спец-поведение: not_started/postponed → большое время в центре вместо счёта; running → LiveBadge; finished → winner подсвечен `EAColor.yellow`; canceled → пилл «Отменён».
- [x] **1.31** Создать `Modules/Tournaments/MatchDetails/Views/MatchGamesList.swift` + `GameMapRow.swift`. Список карт (CS2 — `mapName`, Dota — «Игра N»). Слоты добиваются плейсхолдерами до `numberOfGames`. Per-game score **не** отрисовывается — PandaScore Free выдаёт только `winner.id`. Скрывается при `numberOfGames <= 1`.
- [x] **1.32** Создать `Modules/Tournaments/MatchDetails/Views/MatchRostersView.swift`. Использует `opponent.team.players`. Вся секция скрывается если ни у одной команды нет ростера.
- [x] **1.33** Создать `Modules/Tournaments/MatchDetails/Views/MatchStreamsList.swift` + `StreamRow.swift`. Сортировка main → official → others. Skipping section для finished/canceled (нет смысла без VOD). Empty state при `streams.isEmpty` (для not_started/running). `languageFlag` поддерживает ru/en/uk/es/pt-br/de/fr/it/pl/zh/ja/ko/tr/ar и locale-suffix fallback.
- [x] **1.34** Создать `MatchDetailsSkeleton.swift`. Header skeleton (caption + два team-column + центр-колонка), 3-row maps skeleton, 2-row streams skeleton.
- [x] **1.35** Создать `MatchDetailsProtocols.swift`, `MatchDetailsInteractor.swift`, `MatchDetailsViewModel.swift`, `MatchDetailsView.swift`. VM с generation counters (loadGeneration, tournamentGeneration), best-effort secondary fetch tournament context (silent fallback to `.unavailable`).
- [x] **1.36** Реализовать stream-opening logic (`UIApplication.shared.open` с fallback на Safari). Helper `StreamOpener.open(_:onFailure:)`: пробует platform-specific deeplink (`twitch://stream/<channel>`, `youtube://watch?v=<id>`) → fallback `rawUrl` через Safari. Verified в симуляторе: Twitch не установлен → fallback на Safari открыл `twitch.tv/<channel>`.
- [x] **1.37** Скрыть tab bar на детальном экране через `.toolbar(.hidden, for: .tabBar)`. Verified на симуляторе.
- [x] **1.38** Подключить deeplink `gamesearch://match/<id>`. Уже работало с Phase 1.A — теперь пушит реальный `MatchDetailsView`. Verified `xcrun simctl openurl gamesearch://match/1102577` → push в стек.
- [x] **1.39** Аналитика: `match_opened` (✅ из live_strip/tournament в Phase 1.A/1.B), `match_has_streams_count` (Phase 1.C, по факту загрузки match), `match_shared` (Phase 1.C, simultaneousGesture на ShareLink), `stream_opened` (с platform/language/is_main/is_official), `stream_open_failed` (с reason=app_not_installed|invalid_url|other). `tournaments_pulled_to_refresh(screen: match)` и `tournaments_error_shown/retry_tapped(screen: match)` тоже.

### Дополнительные задачи Phase 1.C (вне исходного списка)

- [x] **1.C.1** Расширен `Shared/TournamentsStrings.swift` строками деталей матча (`matchDetailsNavTitle`, `matchSection*`, `matchMapNotStarted`, `matchNoStreams*`, `streamPlatform*`, `streamOpen*`, `streamOfficialBadge`/`streamMainBadge`, `streamOpenFailedToast`, `matchVersusSeparator`, `unknownLanguage`).
- [x] **1.C.2** Расширен `Shared/TournamentsAnalytics.swift` событиями `matchHasStreamsCount(matchId:count:)`, `matchShared(id:)`, `streamOpened(matchId:platform:language:isMain:isOfficial:)`, `streamOpenFailed(matchId:platform:reason:)`. Добавлены вложенные enum'ы `StreamPlatformAnalytics` (с инициализатором из доменного `StreamPlatform`) и `StreamOpenFailReason`.
- [x] **1.C.3** Header MatchHeaderView грузит `tournamentContext` отдельным best-effort запросом `/tournaments/<id>` — silent fallback на `.unavailable` (caption просто не отрисовывается). Это компромисс: VM в одном fetch не получает league/stage caption, потому что `/matches/{id}` payload не включает structured league или stage name.
- [x] **1.C.4** `MatchStreamsList` скрывает секцию для finished/canceled — после матча стримы недоступны (VOD не реализован в MVP).
- [x] **1.C.5** `GameMapRow` не отрисовывает per-game score — PandaScore Free возвращает только `winner.id` для game-объекта; искусственный счёт серии вводил бы в заблуждение. Winner team name отображается под названием карты в `EAColor.yellow`.

### Bugfix-итерация после Phase 1.C (UX-консистентность списка и live-strip)

- [x] **1.C.bug1** Снят `filter[tier]=s,a` из `TournamentsService.fetchTournamentsPage`. Симптом: live-strip показывал live-матчи всех tier'ов (`fetchLives` идёт без фильтра), а listing был ограничен S/A. На реальных данных получалось «live-чип «SPARTA vs ATH» сверху + ниже empty state «Сейчас никто не играет»». Решение — убрать серверный tier-фильтр в листинге; теперь «Сейчас» отражает то же множество турниров, к которым относятся live-матчи в полосе. Если в будущем потребуется скрыть мелочь — добавить UI-фильтр («Только S/A») как user-facing setting (Phase 1+ или Phase 3 Settings). Обновлены: `TournamentsServiceTests.test_fetchTournaments_whenEmptyCache_callsApi` (теперь ассертит `XCTAssertFalse(query.contains { ... "filter[tier]" })`), `docs/tournaments/04-pandascore-api.md` (пример URL без `filter[tier]`).
- [x] **1.C.bug2** Клиентская сортировка списка турниров по tier (S → A → B → C → D → nil) — следствие bug1: после снятия серверного tier-фильтра список засорился D-tier'ом. Сделано: 1) `Tier` теперь `Comparable` через `var rank: Int` (S=0, A=1, B=2, C=3, D=4) — `PandaScore sort=tier` сортирует лексикографически и кладёт S в конец, поэтому tier-sort всегда клиентский. 2) `TournamentSeriesGroup.tier` упрощён до `stages.compactMap(\.tier).min()` (используется новый `Comparable`), приватный `tierRank(_:)` удалён. 3) `TournamentsListViewModel.applyLoadedState` делает **stable sort** по `tier?.rank ?? Int.max` — внутри одного tier'а сохраняется серверный порядок по `begin_at` (asc для running/upcoming, desc для past), nil-tier (любительские турниры) — в конец. Trade-off: при подгрузке последующих страниц пагинации список re-sort'ится, что может создать визуальный shift, если высокий tier придёт на странице 2. На практике PandaScore при `sort=begin_at` высыпает S/A в первой странице (size 30) — приемлемо для MVP. Verified на симуляторе: CS2 «Скоро» — Cologne Major `[S]` сверху → CCT EU Series 3 `[B]` → CCT EU Series 2 `[B]` → Episode 2 `[B]` → ниже C/D-tier.
- [x] **1.C.bug3** «У первого турнира не показывается призовой фонд» — на самом деле затрагивало любую серию, у которой в выбранном сегменте (running / upcoming / past) виден только Group Stage, а призовой фонд PandaScore прикрепил к ещё-не-начавшемуся Playoffs. Симптом на симуляторе: «Europe Series #2 season 2 2026» (serie 10616) → в списке только Group Stage с `prizepool == nil`, при том что у Playoffs (стадия 21038, не в `/running`) prize `50000 USD`. Карточка отображала только даты, без призового. **Решение**: `TournamentsListInteractor.fetchTournamentsPage` теперь **обогащает страницу сиблинг-стадиями серии**. Алгоритм: 1) группирует полученные `[Tournament]` по `serie.id`, 2) для серий, у которых `allSatisfy { $0.prizepool == nil }`, параллельно (через `withTaskGroup`) дёргает `TournamentsService.fetchSeriesTournaments(serieId:)` (`GET /series/<id>/tournaments`, кэш TTL 1ч), 3) подмешивает недостающие стадии в общий `[Tournament]` с дедупликацией по `id`. `hasMore` считается **до** обогащения — иначе размер страницы перестаёт совпадать с серверной страницей. Ошибки fetch'а сиблингов swallow'ятся (silent fallback) — список рендерится в любом случае. Pull-to-refresh теперь дополнительно инвалидирует `series:tournaments:` cache prefix. Побочные плюсы: серия получает корректный `tier = min(stages.tier)` (например, ранее серия видела только D-tier Group Stage, после обогащения tier поднимается до B/A по Playoffs), субтайтл `stageNamesJoined` показывает все стадии серии (`Group Stage · Playoffs` вместо одного `Group Stage`), а дата серии (`beginAt..endAt`) расширяется до фактического диапазона. Новые тесты — `TournamentsListInteractorTests` (4 кейса): обогащение при отсутствии prizepool, skip когда уже есть, fail-safe при ошибке сиблингов, `hasMore` на оригинальной странице. Verified на симуляторе: CS2 «Сейчас» — у «Europe Series #2 season 2 2026 [C]» появился `$50 000`, у «Series 2 2026 [B]» и «Series 3 2026 [B]» — `$25 000`, tier этих серий поднялся с D до B. Trade-off по rate-limit: первая загрузка списка теперь делает +N запросов (где N = число серий без prize в выбранном сегменте), но кэш на 1ч полностью гасит повторы. На практике в одном сегменте N ≈ 5-10, остаётся комфортный запас в лимите 1000 req/h.

### Definition of Done для Phase 1

- [x] Пользователь может: открыть таб → выбрать игру → выбрать сегмент → открыть турнир → открыть матч → открыть стрим. Verified end-to-end на симуляторе.
- [x] Все экраны имеют loading, loaded, empty, error состояния. TournamentsList, TournamentDetails (включая standings/matches/participants sub-states), MatchDetails — все.
- [x] Pull-to-refresh работает везде (TournamentsList, TournamentDetails, MatchDetails).
- [x] Deeplinks работают (тест через `simctl openurl`): `gamesearch://tournaments`, `gamesearch://tournament/<idOrSlug>`, `gamesearch://match/<id>`. Verified.
- [x] Все события аналитики приходят в AppMetrica (type-safe wrapper `TournamentsAnalytics` + enum `TournamentsAnalyticsEvent` со всеми Phase 1 событиями).
- [x] Старый `TournamentsPlaceholderView` сохранён — он переиспользуется в Welcome-flow и пока остаётся для кампании wishlist (`tournaments_wishlist_*` события). Новый универсальный empty/error — `TournamentsEmptyStateView` в `Shared/`.
- [ ] Старый `PandaScoreTournamentsService` удалён или явно deprecated. **Cleanup-task — оставлен на отдельный PR**, чтобы не смешивать с Phase 1.C delivery. Сейчас он переименован в `PlaceholderTournamentsServiceProtocol` (Phase 0.20) и не используется новыми экранами.
- [x] Сборка без warnings. `xcode-tools.BuildProject` — clean, 0 errors / 0 warnings (2026-05-25).

---

## Phase 2 — Favorites & Push (избранное и уведомления)

**Цель**: позволить пользователю подписаться на команду/турнир и получать push.

**Estimated**: 5-7 дней (плюс 2-3 дня на бэкенд).

### Задачи (iOS)

- [ ] **2.1** Создать `Models/Domain/Favorite.swift`.
- [ ] **2.2** Создать `Services/Tournaments/FavoritesService.swift` — локальное хранение через UserDefaults или CoreData.
- [ ] **2.3** Расширить FavoritesService — sync с Firestore (collection `favorites/{anon_uid}/items`).
- [ ] **2.4** Создать `Modules/Tournaments/Favorites/FavoritesViewModel.swift`, `FavoritesTabView.swift`, `Views/FavoriteRow.swift`.
- [ ] **2.5** Добавить сегмент «Мои» в `TournamentsListView`.
- [ ] **2.6** Создать UI «звёздочка» на TournamentDetailsView, MatchDetailsView, TeamProfileView для toggle избранного.
- [ ] **2.7** Реализовать toast «Добавили в избранное» / «Убрали».
- [ ] **2.8** Аналитика: favorite_added, favorite_removed, favorites_segment_opened.

### Задачи (Push iOS)

- [ ] **2.9** Подключить FCM SDK через SPM (Firebase Messaging).
- [ ] **2.10** Запросить permission на push (с onboarding sheet перед запросом).
- [ ] **2.11** Зарегистрировать device token и сохранить в Firestore (`push_subscriptions/{anon_uid}`).
- [ ] **2.12** Обрабатывать UNUserNotificationCenterDelegate (foreground / background).
- [ ] **2.13** Парсить `deeplink` из push payload и роутить через `Router.handleDeeplink`.
- [ ] **2.14** Аналитика push: push_permission_requested, push_permission_granted/denied, push_received, push_opened.

### Задачи (Backend — Cloud Functions)

- [ ] **2.15** Завести Firebase project (если не заведён для этого приложения).
- [ ] **2.16** Создать Cloud Function `refreshTournamentsCache` — cron каждые 30с/5м/1ч, fetch с PandaScore, write в Firestore. (этот же L3 cache из 07-caching-strategy.md)
- [ ] **2.17** Создать Cloud Function `notifyMatchStarting` — cron каждые 5 минут, ищет матчи начинающиеся через 15±5 минут, для каждого ищет подписчиков, отправляет push через FCM.
- [ ] **2.18** Создать Cloud Function `notifyMatchFinished` — webhook или cron по `match.status` change.
- [ ] **2.19** Создать индексы Firestore для эффективных запросов.

### Задачи (Onboarding)

- [ ] **2.20** Создать onboarding sheet (2 страницы): «Следи за турнирами», «Не пропускай матчи».
- [ ] **2.21** Показывать при первом открытии таба (флаг в UserDefaults).
- [ ] **2.22** Аналитика: onboarding_shown, onboarding_next_tapped, onboarding_completed, onboarding_skipped.

### Definition of Done для Phase 2

- [ ] Пользователь может добавлять команды/турниры в избранное.
- [ ] Список «Мои» отображается с актуальной информацией.
- [ ] Push-уведомления приходят за 15 минут до матча подписанной команды.
- [ ] Тап на push открывает соответствующий экран.
- [ ] Firestore-кэш (L3) работает и снимает нагрузку с PandaScore.
- [ ] Onboarding показывается один раз.

---

## Phase 3 — Profiles (команды и игроки)

**Цель**: дать возможность изучать команды и игроков как отдельные сущности.

**Estimated**: 4-6 дней.

### Задачи

- [ ] **3.1** Создать `Services/Tournaments/TeamsService.swift` (fetchTeam, fetchTeamMatches).
- [ ] **3.2** Создать `Services/Tournaments/PlayersService.swift` (fetchPlayer).
- [ ] **3.3** Создать `Modules/Tournaments/TeamProfile/Views/TeamHeaderView.swift`, `TeamRosterList.swift`, `TeamRecentMatchesList.swift`.
- [ ] **3.4** Создать `TeamProfileViewModel.swift`, `TeamProfileView.swift`.
- [ ] **3.5** Сделать игроков в `MatchRostersView` тапаемыми → push на PlayerProfile.
- [ ] **3.6** Сделать команды-участники в `ParticipantsTab` тапаемыми → push на TeamProfile.
- [ ] **3.7** Создать `Modules/Tournaments/PlayerProfile/Views/PlayerHeaderView.swift`.
- [ ] **3.8** Создать `PlayerProfileViewModel.swift`, `PlayerProfileView.swift`.
- [ ] **3.9** Подключить deeplinks `gamesearch://team/<id>` и `gamesearch://player/<id>`.
- [ ] **3.10** Подключить избранное для игроков (kind = `.player`).
- [ ] **3.11** Аналитика: team_opened, player_opened.

### Definition of Done для Phase 3

- [ ] Пользователь может тапнуть на команду в любом списке → открыть профиль команды → увидеть ростер и последние матчи.
- [ ] Аналогично для игроков.
- [ ] Профили работают для CS2 и Dota 2.

---

## Phase 4 — Polish

**Цель**: довести UX до референсного уровня, добавить spoiler-free, виджет.

**Estimated**: 5-7 дней.

### Задачи

- [ ] **4.1** Реализовать `SpoilerWrapper` компонент.
- [ ] **4.2** Скрыть счёт в прошедших матчах по умолчанию.
- [ ] **4.3** Добавить в Settings тогл «Скрывать счёт прошедших матчей».
- [ ] **4.4** Реализовать onboarding-плашку про spoiler-free при первом просмотре past матча.
- [ ] **4.5** Аналитика: spoiler_revealed, spoiler_free_toggled.
- [ ] **4.6** Реализовать `BracketsTab` нормально (с visualization сетки).
- [ ] **4.7** Добавить haptic feedback на ключевых действиях.
- [ ] **4.8** Добавить матchedGeometryEffect для transition list → details (опционально).
- [ ] **4.9** Реализовать настройку «Игра по умолчанию» в Settings.
- [ ] **4.10** Реализовать «Тихие часы для уведомлений» в Settings.
- [ ] **4.11** Доработать accessibility labels на всех элементах.
- [ ] **4.12** Реализовать Dynamic Type поддержку до `.xxxLarge`.

### Definition of Done для Phase 4

- [ ] Spoiler-free работает идеально.
- [ ] Сетка плей-офф визуализирована.
- [ ] Haptic + accessibility на уровне референсных приложений.

---

## Phase 5+ — Future (по обстоятельствам)

Эти задачи не приоритизированы. Берём из бэклога по обстоятельствам.

- [ ] **F.1** Поддержка LoL.
- [ ] **F.2** Поддержка Valorant.
- [ ] **F.3** Поддержка R6.
- [ ] **F.4** iOS Widget «Сегодня играет».
- [ ] **F.5** Live Activity (Dynamic Island) для running матчей с избранной командой.
- [ ] **F.6** iPad-оптимизация (NavigationSplitView).
- [ ] **F.7** Локализация EN.
- [ ] **F.8** Search global (поиск турниров, команд, игроков из одного поля).
- [ ] **F.9** Universal Links (`https://gamesearch.app/...`).
- [ ] **F.10** Переход на PandaScore Pro Live Plan + WebSocket для in-game stats — **обсуждается отдельно**, требует ADR.

---

## Зависимости между фазами

```
Phase 0 (Foundation)
    │
    ▼
Phase 1 (MVP UI) ─────────────► релиз публики
    │
    ▼
Phase 2 (Favorites & Push) ────► релиз
    │
    ├──► Phase 3 (Profiles) ────► релиз
    │
    └──► Phase 4 (Polish) ──────► релиз
              │
              ▼
        Phase 5+ (Future)
```

Phase 2 и Phase 3 могут идти **параллельно** если ресурсы позволяют.

---

## Чек-листы перед релизом каждой фазы

### Per-phase release checklist

- [ ] Все задачи фазы отмечены `[x]`.
- [ ] Definition of Done выполнен.
- [ ] Прогон UI на симуляторе iPhone 17 Pro (см. AGENTS.md).
- [ ] Прогон UI на реальном устройстве хотя бы один раз.
- [ ] Сборка без warnings.
- [ ] Unit-тесты прошли (`xcode-tools.RunAllTests`).
- [ ] Аналитика в дебаге показывает корректные события и параметры.
- [ ] Документация в `docs/tournaments/` обновлена (features-matrix статусы, ADR если применимо).
- [ ] Скриншоты для App Store обновлены (если внешний релиз).

---

## Как агенту обновлять этот roadmap

Когда задача выполнена:
1. Найди её в этом файле.
2. Замени `[ ]` на `[x]`.
3. Обнови `_Last updated:_` внизу файла.
4. Если возникли новые сабтаски — добавь как `[ ] X.Y.Z`.
5. Если фаза завершена — переноси итоги в `features-matrix.md` (меняй status фич с `not started` на `done`).

---

_Last updated: 2026-05-25 (Phase 0 завершена; Phase 1.A завершена — список турниров; Phase 1.B завершена — детали турнира + bugfix-итерации; Phase 1.C завершена — детали матча; post-1.C bugfix: 1) убран серверный `filter[tier]=s,a` для консистентности с live-strip, 2) добавлена клиентская сортировка списка по tier (S → A → B → C → D → nil) — `Tier` стал `Comparable`, sort применяется в `TournamentsListViewModel.applyLoadedState` stable-методом. Verified: CS2 «Скоро» показывает Cologne Major S сверху → CCT EU B → ниже C/D.)_
