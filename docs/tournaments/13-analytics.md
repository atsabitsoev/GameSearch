# 13 — Analytics

Аналитика модуля «Турниры» через **AppMetrica** (уже подключён в проекте через локальный SPM-пакет `AnalyticsModule`).

Цель — собрать минимально достаточный набор событий, чтобы понимать:
- какие фичи реально используются,
- где пользователи отваливаются (drop-off),
- что приоритизировать в следующих фазах.

---

## Принципы трекинга

1. **Events, not page views.** Трекаем действия пользователя, не просто факт показа экрана.
2. **Параметры — snake_case.** `tournament_id`, `from_screen`.
3. **Значения параметров — короткие.** `live` вместо `is_currently_running`.
4. **Не отправляем PII.** Никаких персональных данных, email, имени.
5. **Имя события — `<noun>_<verb>`** (`tournament_opened`, `match_opened`, `stream_opened`).
6. **AppMetrica имеет лимит 1000 параметров на проект** — экономим, не плодим.
7. **Не дублируем системные метрики** — AppMetrica сама трекает запуск, краш, ANR, retention.

---

## Существующие события модуля

Уже отправляются из `TournamentsPlaceholderView`:

| Event | Когда | Параметры |
|---|---|---|
| `tournaments_wishlist_tap` | Нажата кнопка «Да хочу!» | — |
| `tournaments_wishlist_confirm_shown` | Показан confirmation-toast | — |

**Решение**: оставить эти события до окончательного удаления placeholder — это исторический baseline interest. После удаления placeholder — удалить и события.

---

## Новые события — MVP

### Навигация

| Event | Когда | Параметры |
|---|---|---|
| `tournaments_tab_opened` | Открыт таб «Турниры» | — |
| `tournaments_segment_switched` | Сменён сегмент Running/Upcoming/Past | `segment: running\|upcoming\|past` |
| `tournaments_game_switched` | Сменена игра (CS2/Dota 2) | `game: cs2\|dota2` |
| `tournaments_list_scrolled_to_bottom` | Пользователь долистал до конца | `page: <int>` |
| `tournaments_pulled_to_refresh` | Pull-to-refresh | `screen: list\|details\|match` |

### Турнир

| Event | Когда | Параметры |
|---|---|---|
| `tournament_opened` | Открыт экран деталей турнира | `tournament_id: <int>`, `tournament_slug: <str>`, `from_screen: list\|live_strip\|deeplink\|favorites` |
| `tournament_tab_switched` | Сменена вкладка в деталях турнира | `tab: matches\|standings\|brackets\|participants` |
| `tournament_shared` | Тап «Поделиться» | `tournament_id: <int>` |

### Матч

| Event | Когда | Параметры |
|---|---|---|
| `match_opened` | Открыт экран матча | `match_id: <int>`, `status: not_started\|running\|finished\|canceled\|postponed`, `from_screen: list\|tournament\|live_strip\|deeplink\|favorites` |
| `match_has_streams_count` | Записывается при загрузке деталей матча | `count: <int>`, `match_id: <int>` |
| `match_shared` | Тап «Поделиться» матчем | `match_id: <int>` |

### Стрим (важный для product)

| Event | Когда | Параметры |
|---|---|---|
| `stream_opened` | Тап на стрим в деталях матча | `match_id: <int>`, `platform: twitch\|youtube\|other`, `language: <str>`, `is_main: true\|false`, `is_official: true\|false` |
| `stream_open_failed` | Не удалось открыть стрим | `match_id: <int>`, `platform: <str>`, `reason: app_not_installed\|invalid_url\|other` |

### Live

| Event | Когда | Параметры |
|---|---|---|
| `live_strip_shown` | Live Strip отрисован с N матчами | `count: <int>`, `game: cs2\|dota2` |
| `live_strip_chip_tapped` | Тап на live-чип | `match_id: <int>`, `position: <int>` |

### Ошибки

| Event | Когда | Параметры |
|---|---|---|
| `tournaments_error_shown` | Показан error state | `screen: list\|details\|match`, `kind: no_internet\|temporary` |
| `tournaments_error_retry_tapped` | Тап «Повторить» в error state | `screen: <str>`, `kind: <str>` |

### Кэш (для дебага)

| Event | Когда | Параметры |
|---|---|---|
| `tournaments_fetch` | Service вернул данные | `layer: memory\|disk\|firestore\|network`, `key_prefix: <str>` |
| `tournaments_rate_limited` | Получен 429 | `endpoint: <str>` |

---

## События — Phase 1 (Favorites + Push)

### Избранное

| Event | Когда | Параметры |
|---|---|---|
| `favorite_added` | Добавлена подписка | `kind: team\|tournament\|player`, `entity_id: <int>`, `from_screen: <str>` |
| `favorite_removed` | Удалена подписка | `kind: team\|tournament\|player`, `entity_id: <int>` |
| `favorites_segment_opened` | Открыт сегмент «Мои» | `count: <int>` |
| `favorites_empty_shown` | Показан empty state «Мои» | — |

### Push permission

| Event | Когда | Параметры |
|---|---|---|
| `push_permission_requested` | Запрошен permission | `from_screen: <str>` |
| `push_permission_granted` | Разрешено | — |
| `push_permission_denied` | Отклонено | — |
| `push_permission_skipped` | «Не сейчас» | — |
| `push_received` | Получено уведомление (через `didReceive`) | `kind: match_starting\|match_finished\|tournament_started`, `team_id\|tournament_id: <int>` |
| `push_opened` | Тап на push открыл приложение | `kind: <str>` |

### Onboarding

| Event | Когда | Параметры |
|---|---|---|
| `onboarding_shown` | Показан onboarding | — |
| `onboarding_next_tapped` | Тап «Дальше» | `page: <int>` |
| `onboarding_completed` | Тап «Понятно» на последней странице | — |
| `onboarding_skipped` | Закрыт по свайпу | `page: <int>` |

---

## События — Phase 2 (Teams & Players)

| Event | Когда | Параметры |
|---|---|---|
| `team_opened` | Открыт профиль команды | `team_id: <int>`, `from_screen: <str>` |
| `player_opened` | Открыт профиль игрока | `player_id: <int>`, `from_screen: <str>` |
| `team_recent_matches_loaded` | Загружены недавние матчи команды | `team_id: <int>`, `count: <int>` |

---

## События — Phase 3 (Polish)

| Event | Когда | Параметры |
|---|---|---|
| `spoiler_revealed` | Раскрыт спойлер | `entity: match\|tournament`, `entity_id: <int>` |
| `spoiler_free_toggled` | Тогл в Settings | `enabled: true\|false` |
| `quiet_hours_changed` | Изменены тихие часы | `from: HH:mm`, `to: HH:mm` |

---

## Funnel-метрики

Из этих событий собираются ключевые воронки:

### Funnel A — «Открытие → подписка»
```
tournaments_tab_opened
    → tournament_opened
        → favorite_added (kind=tournament)
```

Цель: % пользователей, которые подписались на турнир ≥ 1 раз / открыли таб.

### Funnel B — «Открытие → стрим»
```
tournaments_tab_opened
    → match_opened
        → stream_opened
```

Цель: % пользователей, дошедших до стрима.

### Funnel C — «Push → реактивация»
```
push_received
    → push_opened
        → match_opened (того же id)
```

Цель: эффективность push-кампаний.

---

## Имплементация в коде

### Helper

В проекте уже есть `AppMetricaReporter` (в `AnalyticsModule`). Используем его:

```swift
import AnalyticsModule

AppMetricaReporter.reportEvent("tournament_opened",
                               parameters: [
                                "tournament_id": tournament.id,
                                "tournament_slug": tournament.slug,
                                "from_screen": "list"
                               ])
```

### Wrapper (опционально)

Для type-safety можно завести enum:

```swift
enum TournamentsAnalyticsEvent {
    case tournamentsTabOpened
    case tournamentOpened(id: Int, slug: String, fromScreen: String)
    case streamOpened(matchId: Int, platform: StreamPlatform, language: String)
    // ...

    var name: String {
        switch self {
        case .tournamentsTabOpened: "tournaments_tab_opened"
        case .tournamentOpened: "tournament_opened"
        case .streamOpened: "stream_opened"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .tournamentsTabOpened: [:]
        case .tournamentOpened(let id, let slug, let from):
            ["tournament_id": id, "tournament_slug": slug, "from_screen": from]
        case .streamOpened(let matchId, let platform, let lang):
            ["match_id": matchId, "platform": String(describing: platform), "language": lang]
        }
    }
}

enum TournamentsAnalytics {
    static func report(_ event: TournamentsAnalyticsEvent) {
        AppMetricaReporter.reportEvent(event.name, parameters: event.parameters)
    }
}
```

Это не обязательно в MVP, но в Phase 3 имеет смысл — избавляет от ошибок в именах строк.

---

## Где НЕ ставить трекеры

- В каждой ячейке `LazyVStack` при отрисовке — это не «событие пользователя», это просто render.
- В каждом `onChange` (например, изменение state) — будет шум.
- В debug-флагах — только реальные user actions.
- На каждый mapper-вызов — это деталь реализации.

---

## Проверка в дебаге

AppMetrica имеет debug-режим — все события логируются в консоль. Включается через переменную окружения или конфиг (см. `AnalyticsModule`).

В Xcode при разработке смотрим консоль на:
```
[AppMetrica] event: tournaments_tab_opened, params: {}
```

Это позволяет проверить, что события отправляются с правильными параметрами.

---

_Last updated: 2026-05-25_
