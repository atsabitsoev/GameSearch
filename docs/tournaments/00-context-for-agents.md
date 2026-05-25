# 00 — Context for Agents

> **Read this file first** if you are an AI agent entering this project in a fresh chat. It is the onboarding text that bridges all sessions and prevents context loss.

---

## TL;DR за 60 секунд

- Мы строим модуль **«Турниры»** для iOS-приложения **GameSearch** — трекер киберспортивных событий по CS2 и Dota 2 (на старте), с прицелом на расширение игр позже.
- Источник данных — **PandaScore REST API**, бесплатный план (1000 req/hour, без беттинга).
- Стек: **SwiftUI, iOS 18+, VIPER-подобная архитектура, Firebase (Firestore + FCM), AppMetrica.**
- В проекте уже есть placeholder-модуль и заготовка `PandaScoreTournamentsService`. Расширяем — не переписываем заново.
- Документация в `docs/tournaments/` — это единственный источник истины. Прежде чем принимать архитектурное решение — найди уже существующий ADR в `decisions/`.

---

## Что обязательно знать о проекте

### Стек и инфраструктура
- **iOS 18+**, **SwiftUI**, **Swift 5.10+**, Xcode 16+.
- **Bundle ID**: `com.bitsoev.gamesearchea`.
- **Симулятор по умолчанию**: `iPhone 17 Pro` (UUID `8A4A9C9D-01CB-4E07-962D-8C3E58E3ED14`).
- **Firebase** уже подключён (Firestore используется для клубов, можно расширять на турниры).
- **AppMetrica** уже подключена через локальный SPM-пакет `AnalyticsModule`.
- **MCP-серверы**: `xcode-tools` (build/test) и `XcodeBuildMCP` (симулятор/UI/LLDB). Правила использования — в корневом `/AGENTS.md`.

### Архитектурный паттерн
Проект использует **VIPER-подобную структуру**: `Service → Interactor → ViewModel → View`, плюс `Router` для навигации и `ScreenFactory` для DI. Этот же паттерн расширяем на турниры — см. `08-modules-and-files.md`.

### Текущее состояние модуля турниров

**Phase 0 (Foundation) — завершена.** Сервисный слой, кэш L1/L2, модели, mappers, роутер, фабрика — на месте. Покрыто 48 unit-тестами.

**Phase 1.A (Список турниров) — завершена.**
- `GameSearch/Modules/Tournaments/TournamentsList/` — VIPER-стек (View/ViewModel/Interactor/Protocols) поверх `TournamentsService` и `MatchesService`.
- `GameSearch/Modules/Tournaments/TournamentsList/Views/` — `GameSegmentControl`, `TournamentSegmentControl`, `TournamentCard`, `LiveMatchChip`, `LiveMatchesStrip`, `TournamentsSkeletonList`.
- `GameSearch/Modules/Tournaments/Shared/` — `TierBadge`, `LiveBadge`, `TeamLogo`, `DateRangeLabel`, `CountryFlag`, `PrizepoolLabel`, `ScoreView`, `GameAccentColor`, `TournamentsEmptyStateView`, `TournamentsStrings`, `TournamentsAnalytics`.
- `Factory/ScreenFactory.makeTournamentsView()` — теперь отдаёт реальный `TournamentsListView`.
- `Router/RootView.swift` — таб «Турниры» обёрнут в `NavigationStack(path: $tournamentsRouter.path)` + `.navigationDestination(for: TournamentsRoute.self)`. Deeplinks `gamesearch://tournaments`, `gamesearch://tournament/<id>`, `gamesearch://match/<id>` работают (URL scheme `gamesearch` зарегистрирован в `Info.plist`).
- `Modules/Tournaments/TournamentsPlaceholderView.swift` (legacy) — пока сохранён, удалить когда уберём `PandaScoreTournamentsService` (DoD Phase 1).

**Phase 1.B (Детали турнира) — завершена + post-Phase-1.B bugfix-итерация по результатам разбора через Proxyman.**
- `GameSearch/Modules/Tournaments/TournamentDetails/` — VIPER-стек (`TournamentDetailsProtocols`, `TournamentDetailsInteractor`, `TournamentDetailsViewModel`, `TournamentDetailsView`).
- `GameSearch/Modules/Tournaments/TournamentDetails/Views/` — `TournamentHeaderView` (hero-карточка), `TournamentStagePicker` (горизонтальный picker сиблингов-стадий серии), `TournamentTabPicker` (4 таба горизонтально-скроллируемые), `MatchesTab` + локальный `MatchRowView` + `MatchRowSkeleton`, `StandingsTab` + `StandingRow` + `StandingsRowSkeleton` + `StandingsColumnLayout`, `ParticipantsTab` + `ParticipantTeamCard`, `BracketsTab` (заглушка), `TournamentDetailsSkeleton`.
- `Shared/MatchTimeFormatter.swift` — `ru_RU` форматтер времени матча (`upcoming` / `finished` / `clock`). Будет переиспользован в 1.C.
- `Shared/TournamentsStrings.swift` — расширен строками деталей (`tournamentTab*`, `standingsCol*`, `participants*`, `time*`, `matchStatusFinished/Canceled/Postponed`).
- `Shared/TournamentsAnalytics.swift` — добавлены `tournamentTabSwitched(id:tab:)`, `tournamentShared(id:slug:)`, enum `TournamentTab`, screen-case `.tournament` для `matchOpened.fromScreen`.
- `Factory/ScreenFactory.makeTournamentDetailsView(idOrSlug:)` — отдаёт реальный `TournamentDetailsView`, инжектирует `tournamentsService` + `matchesService` + `cacheStore`. Placeholder остался только для `makeMatchDetailsView(id:)`.

**Архитектура загрузки данных деталей (важный паттерн для Phase 1.C):**
1. **Tournament details** — `TournamentsService.fetchTournamentDetails(idOrSlug:)` → `GET /tournaments/<idOrSlug>`. Возвращает `Tournament` с `participants` (для таба «Команды»). Inline `tournament.matches` **намеренно игнорируются**, т.к. они приходят без `opponents`, `results`, `league_id`, `videogame` — невозможно отрисовать как карточку матча.
2. **Матчи турнира** — `MatchesService.fetchTournamentMatches(tournamentId:)` → `GET /matches?filter[tournament_id]=<id>&page[size]=100&sort=begin_at`. Возвращает полные `[Match]` с opponents/results/streams/games. VM запускает этот fetch автоматически сразу после успешного `loadTournament`, потому что таб «Матчи» — дефолтный. Cache TTL: 60s для live-сетов, 1ч для статичных.
2a. **Сиблинги-стадии серии** — `TournamentsService.fetchSeriesTournaments(serieId:)` → `GET /series/<id>/tournaments`. Возвращает `[Tournament]` для всех стадий той же серии. VM кикает один раз после первого `loadTournament` (детектит дубликаты через `stagesRequestedForSerieId`). Если стадий > 1 → отрисовываем `TournamentStagePicker`. Тап на чип → `onSelectStage(_:)` меняет `activeIdOrSlug`, ресетит matches/standings sub-states, перезапускает `loadTournament`. Stages list reuse — не перефетчим siblings.
3. **Standings** — `TournamentsService.fetchStandings(tournamentId:)` → `GET /tournaments/<id>/standings`. Lazy fetch (только при первом тапе на таб «Таблица»). **Два формата** в зависимости от типа стадии:
   - **Group/Swiss stage** → полная shape `{rank, team, wins, losses, ties, total, game_wins, game_losses, game_ties}`. Пример: Astana 2026 Group Stage (id 20902, 16 команд с реальной статистикой).
   - **Playoff bracket** → минимальная `{rank, team, last_match}`. Пример: Astana 2026 Playoffs (id 20930). Бракет сам передаёт прогрессию.
   - `Standing` модель имеет все эти поля опциональными. `StandingsTab` через `StandingsColumnLayout(standings:)` индивидуально скрывает каждую stat-колонку если у всех записей nil → group stage показывает `# | Команда | В | П | Игр | Карты`, playoff деградирует до `# | Команда`.
4. **Brackets** — заглушка (Phase 4 polish).
5. **Participants** — derive из `tournament.participants` (без отдельного запроса).

- Share: `ShareLink` с URL `gamesearch://tournament/<slug>` показывается только в `.loaded` state. `simultaneousGesture` отправляет analytics на нажатие.
- Подтверждено в Proxyman: открытие Astana 2026 Playoffs → 2 запроса (`/tournaments/cs-go-pgl-astana-2026-playoffs` + `/matches?filter[tournament_id]=20930`) → таб «Матчи» отрисовывает реальные 8 матчей с командами/счётами; открытие Cologne Major 2026 Stage 1 → тоже 2 запроса → 7 матчей рендерятся с лого. Pull-to-refresh инвалидирует обе кэш-записи.

**Phase 1.C (Детали матча) — завершена.**
- `GameSearch/Modules/Tournaments/MatchDetails/` — VIPER-стек (`MatchDetailsProtocols`, `MatchDetailsInteractor`, `MatchDetailsViewModel`, `MatchDetailsView`).
- `GameSearch/Modules/Tournaments/MatchDetails/Views/` — `MatchHeaderView` (caption «League · Stage» + двух-командный hero + BoX/LIVE/счёт/время), `MatchGamesList` + `GameMapRow` (карты CS2 / игры Dota 2, плейсхолдеры до `numberOfGames`, winner подсвечен `EAColor.yellow`, per-game score намеренно не отрисован — PandaScore Free возвращает только `winner.id`), `MatchStreamsList` + `StreamRow` (sort main → official → others, language flag + display name для 15 локалей, native deeplink в Twitch/YouTube → fallback на Safari через `UIApplication.shared.open`), `MatchRostersView` (опционально, из `opponent.team.players`), `MatchDetailsSkeleton`.
- `Shared/TournamentsStrings.swift` — расширен строками матча (`matchDetailsNavTitle`, `matchSection*`, `streamPlatform*`, `streamOpen*`, `streamOpenFailedToast` для toast'а, `matchVersusSeparator`).
- `Shared/TournamentsAnalytics.swift` — добавлены события `matchHasStreamsCount(matchId:count:)`, `matchShared(id:)`, `streamOpened(matchId:platform:language:isMain:isOfficial:)`, `streamOpenFailed(matchId:platform:reason:)`. Type-safe enum'ы `StreamPlatformAnalytics` (с инициализатором из доменного `StreamPlatform`) и `StreamOpenFailReason`.
- `Factory/ScreenFactory.makeMatchDetailsView(id:)` — отдаёт реальный `MatchDetailsView`. `TournamentsPhasePlaceholder` удалён.

**Архитектура загрузки данных деталей матча (важно для Phase 2/3):**
1. **Match details** — `MatchesService.fetchMatchDetails(id:)` → `GET /matches/<id>`. Возвращает полный `Match` с opponents/results/games/streams + опциональным `opponent.team.players` (когда PandaScore их выдаёт).
2. **Tournament context (caption)** — best-effort secondary fetch `TournamentsService.fetchTournamentDetails(idOrSlug: String(match.tournamentId))`. Silent fallback в `.unavailable` — экран не падает, caption просто не отрисовывается. Это компромисс: `/matches/{id}` не содержит structured `league.name` / `stage.name`, поэтому второй request — единственный способ показать «PGL Major · Group Stage».
3. **Streams** — section показывается только для `notStarted` / `running` / `postponed`. Для finished/canceled section полностью скрывается (нет VOD-поддержки в MVP). `StreamOpener.open(_:onFailure:)` пробует platform-specific deeplink (`twitch://stream/<channel>`, `youtube://watch?v=<id>`) → fallback `rawUrl` через Safari. Toast «Не получилось открыть стрим» через `.alert(...)` показывается только если **оба** пути упали.
4. **Rosters** — derive из `opponent.team.players?`. Вся секция скрывается если ни у одной команды нет ростера. Тапы по игрокам — Phase 2 (PlayerProfile).
5. **Share**: `ShareLink` с URL `gamesearch://match/<id>` показывается только в `.loaded` state. `simultaneousGesture` отправляет `matchShared` analytics на нажатие.
6. **TabBar скрыт** через `.toolbar(.hidden, for: .tabBar)` — даёт ощущение «глубины» для match details (см. `10-screens.md`).
7. **`gamesearch://match/<id>` deeplink** — работало с Phase 1.A (`RootView.handleUrl`), теперь пушит реальный `MatchDetailsView` вместо placeholder. Verified `xcrun simctl openurl`.

End-to-end проверка на симуляторе: open «Турниры» → live-chip «NTR vs OXUJI» → push MatchDetailsView → header с лого команд, BO3, LIVE, 1:0, caption «CIS LAN Championship · Group A», карты (Карта 1 winner=NTR в yellow, Карта 2 LIVE, Карта 3 «Не начато»), стрим mpkbk (русский, Главный/Официальный) → тап → Safari открыл `twitch.tv/mpkbk` (fallback после неудачного `twitch://`).

**Post-Phase-1.C bugfix-итерация (UX-консистентность списка):**
1. **`filter[tier]=s,a` снят с listing-запроса** в `TournamentsService.fetchTournamentsPage`. Live-strip пуллит live матчи всех tier'ов (без фильтра), а listing был ограничен S/A — пользователь видел live-чип, но empty state «Сейчас никто не играет». Если в будущем потребуется опционально скрывать мелочь — это UI-фильтр для пользователя (Settings Phase 3), а не серверный фильтр.
2. **Клиентская сортировка списка по tier**: `Tier` теперь `Comparable` (поле `rank: Int` где S=0, A=1, …, D=4). `TournamentsListViewModel.applyLoadedState` делает **stable sort** по `tier?.rank ?? Int.max` после группировки в `[TournamentSeriesGroup]`. Внутри одного tier сохраняется серверный порядок по `begin_at`. `nil`-tier (любительские турниры) — в конец. Серверный `sort=tier` не годится — PandaScore сортирует строки лексикографически («a» < «b» < … < «s»), кладя S в конец. Тот же `Comparable` упростил `TournamentSeriesGroup.tier` до `stages.compactMap(\.tier).min()`. Caveat: при пагинации (loadNextPage) re-sort применяется, и если высокий tier пришёл на странице 2 — будет визуальный сдвиг. На практике первая страница (size 30) при `sort=begin_at` обычно содержит все S/A — приемлемо для MVP.
3. **Sibling-stages enrichment в listing'е** (`TournamentsListInteractor`). PandaScore прикрепляет prizepool только к Playoffs/Final-стадии серии. Если в выбранном сегменте (`/running`, `/upcoming`, `/past`) от серии виден только Group Stage, а Playoffs ещё не начался — карточка серии оставалась без prizepool, без правильного `tier` и с неполным subtitle. **Фикс**: interactor после получения страницы группирует по `serie.id`, для серий с `allSatisfy { $0.prizepool == nil }` параллельно (`withTaskGroup`) дёргает `TournamentsService.fetchSeriesTournaments(serieId:)` (TTL 1ч), и подмешивает недостающие стадии в общий `[Tournament]` с дедупликацией по `id`. `hasMore` считается **до** enrichment (иначе размер страницы перестаёт совпадать с серверным). Ошибки сиблинг-fetch'а silent fallback — листинг рендерится в любом случае. Pull-to-refresh инвалидирует ещё и `series:tournaments:` cache prefix. Trade-off по rate-limit: +N запросов (N = число серий без prize в сегменте, обычно 5-10), полностью гасится кэшем 1ч. **Важно для Phase 2 (Favorites)**: при выводе списков «избранных серий» используйте тот же паттерн — иначе призовой будет не показан для серий, у которых Playoffs ещё не начался. Покрытие — `TournamentsListInteractorTests` (4 кейса).

**Phase 1 (MVP) — ЗАВЕРШЕНА.** Phase 2 (Favorites & Push) — следующая. Перед стартом — смотри `15-roadmap.md` секция Phase 2 и `02-features-matrix.md`.

**Что точно НЕ трогать (Phase 0 контракт):**
- Сигнатуры `TournamentsServiceProtocol.fetchTournaments(game:segment:)` и `fetchTournamentsPage(game:segment:page:pageSize:)` — page=1 со значением pageSize=50 сохраняет старый cache key для совместимости с Phase 0 тестами.
- `MatchesServiceProtocol` — все методы (`fetchMatches`, `fetchMatchDetails`, `fetchLives`, `fetchTournamentMatches`).
- Старый `PandaScoreTournamentsService` (он же `PlaceholderTournamentsServiceProtocol`) — продолжает работать как раньше, удалить только в конце Phase 1. **Сейчас Phase 1 завершена — placeholder можно удалить отдельным cleanup-PR.**

**Важно**: при создании новых экранов в Phase 2/3 — переиспользовать `Shared/` компоненты (`TournamentsStrings`, `TournamentsAnalytics`, `TeamLogo`, `LiveBadge`, `ScoreView`, `MatchTimeFormatter`, `CountryFlag`). Для match-карточек (Favorites Phase 2, TeamRecentMatchesList Phase 3) — паттерн уже есть в `Modules/Tournaments/TournamentDetails/Views/MatchesTab.swift::MatchRowView`. Для player-карточек — `Modules/Tournaments/MatchDetails/Views/MatchRostersView.swift` (приватный `TeamRosterCard`) или `Modules/Tournaments/TournamentDetails/Views/ParticipantTeamCard.swift`. Для stream-открытия (если когда-нибудь понадобится в Phase 2) — переиспользовать `Modules/Tournaments/MatchDetails/Views/StreamRow.swift::StreamOpener`.

---

## Где что искать

| Вопрос | Файл |
|---|---|
| Зачем мы это делаем и для кого? | `01-vision-and-scope.md` |
| Что мы реализуем, а что отбрасываем? | `02-features-matrix.md` |
| Как делают конкуренты? | `03-competitors.md` |
| Какие эндпоинты PandaScore, какие лимиты, биллинг? | `04-pandascore-api.md` |
| Как устроены слои и потоки данных? | `05-architecture.md` |
| Какие domain-модели использовать? | `06-data-models.md` |
| Как кэшировать и обходить лимит 1000 req/hour? | `07-caching-strategy.md` |
| Какие файлы создаём, куда их класть? | `08-modules-and-files.md` |
| Правила UX в нашем приложении? | `09-ux-principles.md` |
| Wireframes экранов, что где? | `10-screens.md` |
| Какие компоненты, цвета, шрифты использовать? | `11-design-system.md` |
| Какие строки на русском показывать? | `12-microcopy-ru.md` |
| Какие события AppMetrica отправлять? | `13-analytics.md` |
| Какие URL-схемы и навигация? | `14-deeplinks.md` |
| Какой план разработки и в каком порядке? | `15-roadmap.md` |
| Как именовать файлы, классы, как писать код? | `16-coding-conventions.md` |
| Как и что тестировать? | `17-testing.md` |
| Почему мы выбрали именно это? | `decisions/ADR-XXX-*.md` |

---

## Правила работы для агента

### 1. Сначала читать, потом писать
Прежде чем создавать новый файл, класс, экран — найди существующий аналог:
- Service-слой: посмотри `Services/News/ArticlesService.swift` и `Services/Clubs/FirestoreService.swift`.
- UI-список: посмотри `Modules/Clubs/ClubList/` и `Modules/Articles/ArticlesList/`.
- UI-детали: `Modules/Clubs/ClubDetailsView/` и `Modules/Articles/ArticleDetails/`.
- Routing: `Router/ClubsRouter.swift` и `Router/Deeplink.swift`.

### 2. Не дублировать решения, ссылаться на ADR
Если предлагаешь архитектурное решение — сверься с `decisions/`. Если решение там есть, следуй ему. Если хочешь оспорить — создай новый ADR со ссылкой `Supersedes: ADR-XXX`.

### 3. UI делать в соответствии с design system
Все цвета — через `EAColor`, шрифты — через `EAFont`. Не вводить hardcoded значения. См. `11-design-system.md`.

### 4. Все строки на русском вынесены в `12-microcopy-ru.md`
Если нужна новая строка — добавь туда, потом используй в коде. Это упростит локализацию в будущем (Phase 4).

### 5. После завершения видимого изменения — обновить документацию
Если изменился контракт, добавилась фича, перенеслась задача из Phase 2 в MVP — обнови соответствующий .md. Это часть Definition of Done.

### 6. Build & test через MCP
Сборка — `xcode-tools.BuildProject`. Запуск на симуляторе — `XcodeBuildMCP.install_app_sim + launch_app_sim`. Подробности — в корневом `AGENTS.md`. Не использовать `xcodebuild` напрямую без необходимости.

### 7. Никогда не коммитить и не пушить без явной просьбы пользователя
Это правило проекта. Изменения локально — да, git operations — только по запросу.

---

## Что должно остаться unchanged без обсуждения

- **Стек**: SwiftUI, VIPER-подобная архитектура, Firebase + AppMetrica. Не предлагать TCA, Redux, RxSwift, UIKit-only переходы.
- **Источник данных**: PandaScore. Не предлагать перейти на Liquipedia parsing / HLTV unofficial / собственный парсинг.
- **Игры на старте**: CS2 + Dota 2. Не добавлять Valorant/LoL в MVP — Phase 3.
- **Стримы**: deeplink в Twitch/YouTube. Не embed в WebView в MVP (см. ADR-003).
- **Беттинг и фэнтези**: запрещены лицензией PandaScore Free, не предлагать (см. ADR-005).

Если ситуация требует пересмотра — это нормально, но это **отдельный разговор с пользователем**, не молчаливое решение.

---

## Definition of Done для любой задачи модуля

Задача из roadmap считается готовой только если:

1. **Код собирается** через `xcode-tools.BuildProject` без warnings (или с обоснованным suppressed).
2. **Сценарий работает** на симуляторе `iPhone 17 Pro` (проверка через `screenshot` или ручной запуск).
3. **Нет hardcoded цветов и шрифтов** — всё через `EAColor` / `EAFont`.
4. **Нет hardcoded строк русского текста** — через `12-microcopy-ru.md`.
5. **Аналитика добавлена**, если задача затрагивает новый user flow (см. `13-analytics.md`).
6. **Документация обновлена**, если изменился контракт/архитектура.
7. **Roadmap обновлён** — соответствующая задача отмечена как `[x]` в `15-roadmap.md`.

---

## Контакты и эскалация

- Пользователь (владелец проекта) — единственный stakeholder. Все продуктовые и архитектурные сомнения адресуются ему через сообщение в чате.
- Если задача неоднозначна и в документации нет ответа — задать уточняющий вопрос пользователю **до начала кодирования**, а не после.

---

_Last updated: 2026-05-25 (Phase 1.C завершена — детали матча с открытием стримов; Phase 1 в целом завершена. Post-Phase-1.C bugfix #3 — sibling-stages enrichment в listing'е для корректного отображения prizepool/tier/subtitle серий, у которых Playoffs ещё не начался.)_
