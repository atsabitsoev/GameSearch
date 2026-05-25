# 04 — PandaScore API

Единая страница с тем что нужно знать о PandaScore для разработки модуля. Прочитав этот файл, агент должен мочь работать с API без дополнительных запросов в интернет.

---

## База

- **Base URL**: `https://api.pandascore.co`
- **Live WebSocket base** (не используем в MVP): `wss://live.pandascore.co`
- **Формат**: JSON, timestamps в **ISO-8601 UTC**, blank fields = `null`.
- **HTTPS only.**
- **Документация**: <https://developers.pandascore.co/reference> и <https://developers.pandascore.co/docs>

---

## Аутентификация

Два способа, равнозначно:

```http
GET /tournaments HTTP/1.1
Host: api.pandascore.co
Authorization: Bearer YOUR_TOKEN
Accept: application/json
```

или query-параметром:

```
GET /tournaments?token=YOUR_TOKEN
```

В нашем коде используем заголовок `Authorization: Bearer ...` (см. `PandaScoreTournamentsService.fetchTournament`).

Ключ берётся из `Info.plist` ключ `PandaScoreAPIKey`. Если ключа нет — деградируем на кэш и не падаем. **Никогда не коммитим ключ в репо**; в проекте используется механизм config-файла, который не входит в git (см. `.gitignore`).

---

## Лимиты и план

**Free Plan** (наш текущий):

| Параметр | Значение |
|---|---|
| Лимит запросов | **1000 / hour** на API-ключ |
| Регистрация | Без кредитки |
| Покрытие данных | Fixtures-Only: расписание, результаты, команды, игроки, стримы, турниры, серии, лиги |
| WebSockets (live frames) | ❌ нет |
| Events feed | ❌ Pro Live Plan (от ~1000€/мес за игру) |
| Replay API | ❌ Pro |
| Odds API | ❌ Отдельная коммерческая лицензия, требует беттинг-лицензию |
| Использование для беттинга / фэнтези | ❌ **Запрещено лицензией** |

**Pro Plan** (если когда-то понадобится):

| План | Цена | Что добавляет |
|---|---|---|
| Stats Plan | от 400€/мес за игру | 10K req/hour, расширенные статы |
| Pro Live Plan | от 1000€/мес за игру | Real-time WebSocket frames + events |

---

## Стратегия работы с лимитом

При 1000 req/hour клиент-only архитектура не выдержит даже 100 активных пользователей в час пик. Решение — **многоуровневый кэш + Firestore-прокси на бэкенде**. Полные детали — в `07-caching-strategy.md`.

Внутри API-клиента:
- Retry с экспоненциальной задержкой (350 ms, 700 ms, 1400 ms) — макс 2 retry.
- При HTTP 429 — пауза 60 секунд и не повторять текущий запрос.
- При HTTP 5xx — retry; при 4xx (кроме 429) — не retry.
- Все ответы кэшируются in-memory и на диск с TTL зависящим от типа данных.

---

## Параметры запросов (универсальные)

Эти параметры работают на большинстве эндпоинтов-списков:

### Pagination

```
?page[number]=1&page[size]=50
```

- `page[size]` — макс **100**, по умолчанию **50**.
- `page[number]` — начиная с **1**.

### Filter (strict equality)

```
?filter[tier]=s,a&filter[videogame_id]=3
```

Несколько значений — через запятую. Несколько полей — несколько параметров.

> Для дат `filter` сравнивает только дату (day/month/year), время игнорируется. Используй `range` для точного.

### Range (interval)

```
?range[begin_at]=2026-05-25T00:00:00Z,2026-06-01T00:00:00Z
```

Границы **включительные**.

### Search (substring, case-insensitive)

```
?search[name]=major
```

Работает только со строковыми полями.

### Sort

```
?sort=begin_at,-name
```

Несколько полей через запятую. `-` перед полем = descending. Для ascending — `null` идёт первым; для descending — последним.

---

## Эндпоинты, которые мы используем

### Tournaments

| Метод | Путь | Что | Кэш TTL |
|---|---|---|---|
| GET | `/{game}/tournaments/running` | Идущие турниры по игре | 5 мин |
| GET | `/{game}/tournaments/upcoming` | Предстоящие | 30 мин |
| GET | `/{game}/tournaments/past` | Прошедшие | 24 часа |
| GET | `/tournaments/{id_or_slug}` | Детали турнира | 10 мин |
| GET | `/tournaments/{id_or_slug}/standings` | Таблица результатов | 5 мин (если live) / 1 час (если past) |
| GET | `/tournaments/{id_or_slug}/brackets` | Сетка плей-офф | 5 мин (live) / 1 час (past) |

`{game}` = `csgo` для CS2, `dota2` для Dota 2.

Пример полного URL:

```
https://api.pandascore.co/csgo/tournaments/running?filter[tier]=s,a&page[size]=20&sort=-begin_at
```

### Matches

| Метод | Путь | Что | Кэш TTL |
|---|---|---|---|
| GET | `/{game}/matches/running` | Идущие матчи | 30 сек |
| GET | `/{game}/matches/upcoming` | Предстоящие | 5 мин |
| GET | `/{game}/matches/past` | Прошедшие | 24 часа |
| GET | `/matches/{id}` | Детали матча | 30 сек (live) / 24 ч (past) |
| GET | `/lives` | Все live-матчи (агрегированно) | 30 сек |

### Teams

| Метод | Путь | Что | Кэш TTL |
|---|---|---|---|
| GET | `/{game}/teams/{id}` | Профиль команды | 12 часов |
| GET | `/teams/{id}/matches` | Матчи команды | 5 мин |

### Players

| Метод | Путь | Что | Кэш TTL |
|---|---|---|---|
| GET | `/{game}/players/{id}` | Профиль игрока | 12 часов |

### Leagues & Series

| Метод | Путь | Что | Кэш TTL |
|---|---|---|---|
| GET | `/leagues` | Список лиг (для фильтрации) | 24 часа |
| GET | `/series/upcoming` | Серии турниров (LCS Summer и т.п.) | 30 мин |

---

## Структуры ответов (ключевые поля)

Только те поля, которые мы реально показываем в UI. Полная схема — на developers.pandascore.co/reference.

### Tournament

```json
{
  "id": 13420,
  "slug": "csgo-pgl-major-copenhagen-2024",
  "name": "Group Stage",
  "tier": "s",
  "begin_at": "2026-03-21T08:00:00Z",
  "end_at": "2026-03-31T20:00:00Z",
  "prizepool": "1250000 United States Dollar",
  "country": "DK",
  "region": "EUROPE",
  "live_supported": true,
  "league": {
    "id": 4501,
    "name": "PGL",
    "slug": "csgo-pgl",
    "image_url": "https://cdn-api.pandascore.co/.../pgl.png"
  },
  "serie": {
    "id": 6125,
    "name": "Major Copenhagen 2026",
    "full_name": "Major Copenhagen 2026 March",
    "year": 2026,
    "season": null
  },
  "videogame": { "id": 3, "name": "CS-GO", "slug": "cs-go" },
  "matches": [ /* MatchShort[] */ ],
  "expected_roster": [
    {
      "team": { /* Team */ },
      "players": [ /* Player[] */ ]
    }
  ],
  "modified_at": "2026-03-15T12:00:00Z"
}
```

### Match

```json
{
  "id": 1071234,
  "name": "FaZe vs NaVi",
  "status": "running",
  "match_type": "best_of",
  "number_of_games": 5,
  "begin_at": "2026-05-25T15:00:00Z",
  "scheduled_at": "2026-05-25T15:00:00Z",
  "end_at": null,
  "draw": false,
  "forfeit": false,
  "winner_id": null,
  "winner_type": "Team",
  "tournament_id": 13420,
  "serie_id": 6125,
  "league_id": 4501,
  "videogame": { "id": 3, "name": "CS-GO" },
  "opponents": [
    { "type": "Team", "opponent": { /* Team */ } },
    { "type": "Team", "opponent": { /* Team */ } }
  ],
  "results": [
    { "team_id": 411, "score": 1 },
    { "team_id": 412, "score": 0 }
  ],
  "games": [
    {
      "id": 999111,
      "position": 1,
      "status": "finished",
      "winner": { "id": 411, "type": "Team" },
      "begin_at": "2026-05-25T15:05:00Z",
      "end_at": "2026-05-25T15:50:00Z",
      "length": 2700,
      "complete": true,
      "detailed_stats": true,
      "video_url": null
    }
  ],
  "streams_list": [
    {
      "language": "ru",
      "embed_url": "https://player.twitch.tv/?channel=maincast&parent=...",
      "raw_url": "https://www.twitch.tv/maincast",
      "main": true,
      "official": false
    }
  ],
  "live": {
    "supported": true,
    "url": "wss://live.pandascore.co/matches/1071234",
    "opens_at": "2026-05-25T14:55:00Z"
  }
}
```

### Team

```json
{
  "id": 411,
  "name": "FaZe Clan",
  "slug": "faze-clan",
  "acronym": "FAZE",
  "location": "EU",
  "image_url": "https://cdn-api.pandascore.co/.../faze.png",
  "current_videogame": { "id": 3, "name": "CS-GO" },
  "players": [ /* Player[] */ ],
  "modified_at": "2026-05-20T10:00:00Z"
}
```

### Player

```json
{
  "id": 12345,
  "name": "karrigan",
  "first_name": "Finn",
  "last_name": "Andersen",
  "nationality": "DK",
  "age": 35,
  "birthday": "1990-02-25",
  "role": "Coach",
  "active": true,
  "current_team": { /* Team */ },
  "current_videogame": { "id": 3, "name": "CS-GO" },
  "image_url": "https://cdn-api.pandascore.co/.../karrigan.png",
  "modified_at": "2026-04-01T08:00:00Z"
}
```

### Stream (внутри Match)

```json
{
  "language": "ru",
  "embed_url": "https://player.twitch.tv/?channel=maincast&parent=...",
  "raw_url": "https://www.twitch.tv/maincast",
  "main": true,
  "official": false
}
```

Платформа определяется парсингом `raw_url`:
- `twitch.tv/` → Twitch
- `youtube.com/` или `youtu.be/` → YouTube
- остальное → fallback Safari

---

## Tier (важно для фильтрации)

| Tier | Что значит | Примеры |
|---|---|---|
| `s` | Топовый | The International, IEM Katowice, Major |
| `a` | Высокий | ESL Pro League, DreamLeague |
| `b` | Региональный | Различные региональные финалы |
| `c` | Низкий | Малые турниры |
| `d` | Любительский | |

В MVP фильтруем `filter[tier]=s,a` — это убирает шум. В Phase 3 можно дать пользователю настройку «показывать все».

---

## Status матча и турнира

### Match status
- `not_started` — ещё не начался
- `running` — идёт прямо сейчас
- `finished` — завершён
- `canceled` — отменён
- `postponed` — перенесён

### Tournament status
Не имеет явного enum, определяется по датам:
- `begin_at` в будущем → upcoming
- `begin_at <= now < end_at` → running
- `end_at` в прошлом → past

PandaScore даёт это через эндпоинты `/running`, `/upcoming`, `/past` — не надо считать на клиенте.

---

## Поддерживаемые игры

Все 13 игр доступны на free-плане. Префиксы для эндпоинтов:

| Игра | Префикс | Используем |
|---|---|---|
| Counter-Strike (CS2 / CS:GO) | `csgo` | ✅ MVP |
| Dota 2 | `dota2` | ✅ MVP |
| League of Legends | `lol` | Future |
| Valorant | `valorant` | Future |
| Rainbow Six | `r6siege` | Future |
| Call of Duty MW | `codmw` | — |
| Overwatch | `ow` | Future |
| LoL Wild Rift | `lol-wild-rift` | — |
| StarCraft 2 | `sc2` | — |
| Rocket League | `rl` | — |
| KingOfGlory | `kog` | — |
| PUBG | `pubg` | — |
| Mobile Legends | `mlbb` | — |

---

## WebSocket Live API (не используем в MVP)

Краткая справка на случай, если в будущем подключим Pro Live Plan.

```
wss://live.pandascore.co/matches/{match_id}?token=YOUR_TOKEN
wss://live.pandascore.co/matches/{match_id}/events?token=YOUR_TOKEN
```

- **Frames** — снапшоты состояния каждые 2 секунды.
- **Events** — таймлайн событий в реальном времени.
- До 3 одновременных коннектов на матч на endpoint.
- События доступны только в Pro Live Plan.
- Для CS и LoL Frames доступны и в Stats plan (с лимитами).

**Сейчас не нужно.** Если потребуется live-данные — обсудить переход на Pro и обновить ADR.

---

## Юридические и use-case ограничения

PandaScore Free и Stats планы **запрещают** использование данных в:
- беттинг-приложениях,
- фэнтези-приложениях,
- любых платных сервисах с прогнозами и коэффициентами.

GameSearch как информационное приложение для фанатов **разрешён**. Если когда-то добавим:
- любую form of betting / odds — нужен отдельный коммерческий контракт с PandaScore (Odds API),
- pay-to-access премиум-функции — формально не запрещено, но стоит уточнить у sales@pandascore.co.

См. также `decisions/ADR-005-no-betting-no-fantasy.md`.

---

## Полезные ссылки

- Reference: <https://developers.pandascore.co/reference>
- Filtering: <https://developers.pandascore.co/docs/filtering-and-sorting>
- WebSockets: <https://developers.pandascore.co/docs/websockets-overview>
- Pricing: <https://www.pandascore.co/pricing>
- Status page: <https://status.pandascore.co>

---

_Last updated: 2026-05-25_
