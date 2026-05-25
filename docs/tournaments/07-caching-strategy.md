# 07 — Caching Strategy

Стратегия кэширования для модуля турниров. Главная мотивация — **обойти лимит PandaScore 1000 req/hour на ключ**, не теряя в UX.

---

## Многоуровневая модель

```
┌─────────────────────────────────────────────────────────────┐
│                     ViewModel / Interactor                  │
└────────────────────────────┬────────────────────────────────┘
                             │ запрос данных
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                          Service                            │
│   читает: L1 → L2 → (L3 если Phase 1+) → Network            │
│   пишет:  Network → L2 → L1                                 │
└─────────────────────────────────────────────────────────────┘
            │                  │                  │
            ▼                  ▼                  ▼
   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
   │ L1: in-memory   │ │ L2: disk JSON   │ │ L3: Firestore   │
   │ NSCache         │ │ Library/Caches/ │ │ (Phase 1+)      │
   │ TTL: session    │ │ TTL: per type   │ │ TTL: per type   │
   │ ~50 MB max      │ │ ~10 MB max      │ │ writes only     │
   │                 │ │                 │ │ on backend      │
   └─────────────────┘ └─────────────────┘ └─────────────────┘
```

---

## TTL по типам данных

Главный принцип: **чем чаще данные меняются, тем короче TTL**.

| Тип данных | L1 TTL | L2 TTL | L3 TTL | Обоснование |
|---|---|---|---|---|
| Live matches list | 30 сек | 30 сек | 30 сек | Меняется постоянно, но за 30с не сильно |
| Running tournament details | 5 мин | 5 мин | 5 мин | Матчи могут добавляться |
| Match details (live) | 30 сек | 30 сек | 30 сек | Счёт меняется по картам |
| Match details (finished) | 24 часа | 7 дней | 7 дней | Не меняется, кешируем агрессивно |
| Upcoming tournaments | 30 мин | 1 час | 30 мин | Меняется редко |
| Past tournaments | 24 часа | 7 дней | 7 дней | Не меняется почти никогда |
| Tournament standings (live) | 5 мин | 5 мин | 5 мин | Обновляется после матча |
| Tournament standings (finished) | 24 часа | 7 дней | 7 дней | Финальная таблица |
| Brackets | 5 мин / 24 часа | как выше | как выше | По live статусу турнира |
| Team profile | 12 часов | 24 часа | 24 часа | Ростер меняется редко |
| Player profile | 12 часов | 24 часа | 24 часа | |
| Leagues list | 24 часа | 7 дней | 7 дней | Почти статика |
| Series list | 30 мин | 1 час | 1 час | Меняется при анонсе новых сезонов |

> **Важно**: TTL для L1 ≤ TTL для L2. L2 — fallback при cold start, L1 — для горячих обращений в сессии.

---

## L1: In-Memory Cache (NSCache)

```swift
actor MemoryCache {
    private let cache: NSCache<NSString, CacheEntry> = {
        let c = NSCache<NSString, CacheEntry>()
        c.totalCostLimit = 50 * 1024 * 1024  // 50 MB
        c.countLimit = 500                    // макс 500 записей
        return c
    }()

    func read<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let entry = cache.object(forKey: key as NSString),
              !entry.isExpired,
              let value = entry.value as? T
        else { return nil }
        return value
    }

    func write<T: Encodable>(_ value: T, key: String, ttl: TimeInterval) {
        let entry = CacheEntry(value: value, expiresAt: Date().addingTimeInterval(ttl))
        cache.setObject(entry, forKey: key as NSString)
    }

    func invalidate(prefix: String) { /* итерируем и удаляем */ }
    func invalidateAll() { cache.removeAllObjects() }
}

private final class CacheEntry {
    let value: Any
    let expiresAt: Date
    var isExpired: Bool { Date() >= expiresAt }
    init(value: Any, expiresAt: Date) { self.value = value; self.expiresAt = expiresAt }
}
```

**Когда инвалидируется**:
- Pull-to-refresh — `invalidate(prefix: "tournaments:")`.
- Изменение фильтра — `invalidate(prefix: "tournaments:filter:")`.
- Logout (для favorites) — `invalidateAll()`.
- Memory warning — автоматически через NSCache.

---

## L2: Disk Cache (FileManager JSON)

```swift
actor DiskCache {
    private let directory: URL
    private let fileManager: FileManager = .default
    private let maxSize: Int64 = 10 * 1024 * 1024  // 10 MB

    init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.directory = caches.appendingPathComponent("Tournaments", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func read<T: Decodable>(_ type: T.Type, key: String) async -> T? {
        let url = directory.appendingPathComponent(safeFilename(key) + ".json")
        guard let data = try? Data(contentsOf: url),
              let envelope = try? JSONDecoder().decode(DiskEnvelope<T>.self, from: data),
              !envelope.isExpired
        else { return nil }
        return envelope.value
    }

    func write<T: Encodable>(_ value: T, key: String, ttl: TimeInterval) async {
        let envelope = DiskEnvelope(value: value, expiresAt: Date().addingTimeInterval(ttl))
        let url = directory.appendingPathComponent(safeFilename(key) + ".json")
        guard let data = try? JSONEncoder().encode(envelope) else { return }
        try? data.write(to: url, options: .atomic)
        await evictIfNeeded()
    }

    private func evictIfNeeded() async {
        // если размер > maxSize — удаляем самые старые по mtime
    }
}

private struct DiskEnvelope<T: Codable>: Codable {
    let value: T
    let expiresAt: Date
    var isExpired: Bool { Date() >= expiresAt }
}
```

**Где хранится**: `~/Library/Caches/Tournaments/` (iOS система может удалить при нехватке места — это OK, mы переживём).

**Когда инвалидируется**:
- Auto-eviction по размеру и mtime.
- Версионирование схемы: если в `DiskEnvelope` менять формат — добавлять `schemaVersion`, инвалидировать все при несовпадении.

---

## L3: Firestore Proxy (Phase 1+)

Это **серверный кэш**, который снимает нагрузку с PandaScore.

### Зачем
- PandaScore лимит = 1000 req/hour на ключ.
- При 200 активных пользователях в час = выгорает за минуты.
- Firestore — почти бесплатный на наших объёмах, очень быстрый read.

### Архитектура

```
                   ┌────────────────────────────┐
                   │   Cloud Function (TS)      │
                   │   refreshTournamentsCache  │
                   │   запускается по cron:     │
                   │   - каждые 30с для live    │
                   │   - каждые 5м для upcoming │
                   │   - раз в час для past     │
                   └─────────────┬──────────────┘
                                 │ HTTP
                                 ▼
                       PandaScore API
                       (один ключ, низкий QPS)
                                 │
                                 ▼
                       Firestore collections:
                       └── tournaments_cache/{...}
                       └── matches_cache/{...}
                       └── lives_cache (single doc)

           ▲ читают                              ▲ читают
           │ (Firebase SDK на iOS)               │
   ┌───────┴──────┐                      ┌───────┴──────┐
   │   User A     │                      │   User B     │
   │   iPhone     │                      │   iPhone     │
   └──────────────┘                      └──────────────┘
```

### Какие данные в L3
**Только публичные, не персональные**:
- Список running/upcoming/past турниров по CS2 и Dota 2.
- Список live матчей.
- Топ-турниры (для главного экрана).

### Какие данные **НЕ** в L3
- Детали конкретного турнира (слишком много — лучше fetch on demand).
- Детали конкретного матча.
- Команды и игроки.

Для деталей пользователь обращается напрямую к PandaScore через клиент (с L1/L2). Если когда-то выясним что и детали раздувают нагрузку — расширим L3.

### Структура документа

```typescript
// tournaments_cache/{game}/{segment}
// e.g. tournaments_cache/csgo/running
{
  payload: Tournament[],          // в формате нашего domain JSON
  fetchedAt: Timestamp,
  ttl: 300,                       // сек, чтобы клиент проверял свежесть
  source: "pandascore",
  schemaVersion: 1,
}
```

### Стоимость
- Firestore reads: 50K free/day. На 1000 DAU при 5 чтениях/день — это 5000 reads/day. Бесплатно.
- Cloud Functions: 2M invocations free/month. Cron каждые 30с = 86400 invocations/day = ~2.6M/месяц. **На пороге — нужно следить.**
- Решение: можно реже запускать live-refresh (например, каждую минуту) и принять небольшое отставание.

### Когда строим L3
Не в MVP. Добавляем когда:
- DAU > 100, и
- Видим повторяющиеся 429 от PandaScore в логах.

До этого работаем на L1+L2 — этого хватит.

---

## Cache key конвенция

```
tournaments:list:{game}:{segment}:{filterHash}     // /tournaments
tournament:detail:{id}                              // /tournaments/{id}
tournament:standings:{id}                           // /tournaments/{id}/standings
tournament:brackets:{id}                            // /tournaments/{id}/brackets
matches:list:{game}:{segment}:{filterHash}
match:detail:{id}
lives:all                                           // /lives
team:detail:{id}
team:matches:{id}
player:detail:{id}
leagues:all
series:upcoming
```

`filterHash` — MD5 от JSON-параметров фильтра (tier, page, sort). Нужен только если включаем кастомные фильтры — для базового MVP не нужен.

---

## Алгоритм Service.fetch (псевдокод)

```swift
func fetchTournaments(game: Game, segment: TournamentSegment) async throws -> [Tournament] {
    let key = "tournaments:list:\(game.rawValue):\(segment)"

    // L1
    if let cached: [Tournament] = await memoryCache.read([Tournament].self, key: key) {
        return cached
    }

    // L2
    if let cached: [Tournament] = await diskCache.read([Tournament].self, key: key) {
        await memoryCache.write(cached, key: key, ttl: ttl(for: segment))
        // Опционально: revalidate в фоне
        Task.detached { await self.refreshInBackground(game: game, segment: segment) }
        return cached
    }

    // L3 (Phase 1+)
    if let cached: [Tournament] = await firestoreProxy?.read(game: game, segment: segment) {
        await diskCache.write(cached, key: key, ttl: ttl(for: segment))
        await memoryCache.write(cached, key: key, ttl: ttl(for: segment))
        return cached
    }

    // Network
    let dto = try await apiClient.get(PandaScoreTournamentsListDTO.self,
                                       path: "/\(game.pandaScorePrefix)/tournaments/\(segment.pandaScorePath)",
                                       query: [...])
    let tournaments = dto.data.compactMap(TournamentMapper.map)

    await diskCache.write(tournaments, key: key, ttl: ttl(for: segment))
    await memoryCache.write(tournaments, key: key, ttl: ttl(for: segment))

    return tournaments
}
```

---

## Стратегия "Stale-While-Revalidate"

Для частых обращений (live матчи, running tournaments) применяем SWR:

1. Если в L1/L2 есть **устаревший** ответ — отдаём его немедленно.
2. Параллельно запускаем фоновый рефреш.
3. После рефреша обновляем кэш и публикуем через ViewModel (если экран ещё открыт).

Это улучшает воспринимаемую скорость в разы — UI никогда не висит на спиннере при возврате на экран.

---

## Что _не_ кэшируем

- Ответы с HTTP 4xx (валидация, auth) — не имеет смысла переиспользовать.
- Ответы с HTTP 5xx — может быть transient, не хотим зафиксировать.
- Пустые ответы — `[]`. Кэш отрицательного результата приведёт к «всегда пусто» при флуктуациях.

---

## Инвалидация

| Триггер | Что инвалидируем |
|---|---|
| Pull-to-refresh на списке | `prefix: "tournaments:list:"` |
| Pull-to-refresh на деталях | `prefix: "tournament:detail:{id}"` |
| Добавление в избранное | ничего из tournaments, только favorites |
| Изменение фильтра | соответствующий списочный ключ |
| Logout | всё (`invalidateAll`) |
| Memory warning | L1 авто, L2 не трогаем |
| Schema migration | всё (по `schemaVersion`) |

---

## Метрики кэша (для дебага)

Заводим простой trace:

```swift
enum CacheLayer { case memory, disk, firestore, network }
let layer = await fetchAndLog(...)
AppMetricaReporter.reportEvent("tournaments_fetch", parameters: ["layer": layer.rawValue, "key": key])
```

После релиза в дашборде смотрим распределение по layer'ам. Если network > 30% — пересматриваем TTL.

---

_Last updated: 2026-05-25_
