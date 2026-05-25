# ADR-002 — Backend Cache via Firestore Proxy

- **Status**: Accepted (для Phase 1+) / Deferred (для MVP)
- **Date**: 2026-05-25
- **Owner**: iOS team / Backend

## Context

PandaScore Free plan имеет лимит **1000 запросов в час на API-ключ**. Если клиенты iOS будут ходить напрямую в PandaScore, то при росте аудитории мы быстро упрёмся в этот лимит:

- 200 активных пользователей в час пик.
- Каждый делает ~15 запросов за сессию (список + детали + матч + переключения).
- = 3000 req/hour, что в 3 раза превышает лимит.

Когда лимит превышается — PandaScore возвращает HTTP 429, и приложение перестаёт работать для **всех** пользователей сразу. Это критичный single point of failure.

Также Firebase уже используется в проекте (Firestore для клубов, Auth для anonymous user id). Добавлять новый backend stack нерационально.

## Decision

Внедряем **трёхуровневую стратегию кэширования** (см. `07-caching-strategy.md`):
- **L1**: in-memory NSCache на клиенте.
- **L2**: disk-based JSON cache на клиенте (Library/Caches).
- **L3** (Phase 1+): Firestore-прокси с Cloud Functions, обновляющими данные по cron.

**Для MVP** реализуем только L1+L2. Этого хватит на ~50-100 активных пользователей в час пик.

**В Phase 1+** добавляем L3, когда выполнятся хотя бы одно из условий:
- DAU > 100.
- Появляются 429-ошибки в логах AppMetrica (`tournaments_rate_limited` event).
- Запускаем publicity-кампанию.

## Alternatives Considered

### А. Только клиентский кэш (без L3)
- **Плюсы**: проще, нет инфраструктуры, нет затрат.
- **Минусы**: на 100+ DAU гарантированно упирается в лимит.
- **Вердикт**: подходит только для MVP с очень малой аудиторией.

### Б. Платный план PandaScore (10K req/hour)
- **Плюсы**: убирает проблему лимита, добавляет live-данные.
- **Минусы**: 400€/мес за каждую игру. Для бесплатного pet-проекта — overkill.
- **Вердикт**: вернёмся к этому, когда будет монетизация.

### В. Собственный backend на отдельном сервере
- **Плюсы**: полный контроль.
- **Минусы**:
  - Нужно поднимать инфраструктуру (VPS / Heroku / fly.io).
  - Платить за хостинг и трафик.
  - Дополнительный stack (Node/Python/Go) — нужно поддерживать.
  - В проекте уже есть Firebase.
- **Вердикт**: дорого и сложно, когда Firebase достаточен.

### Г. Прокси через Cloudflare Workers
- **Плюсы**: бесплатный план достаточно щедрый, edge-сеть.
- **Минусы**:
  - Опять отдельная инфраструктура.
  - Нужен Cloudflare-аккаунт и DNS.
  - Не интегрируется так же гладко с iOS, как Firebase SDK.
- **Вердикт**: разумная альтернатива, но Firebase выигрывает по интеграции.

### Д. PandaScore WebSocket Live + клиент-only
- **Плюсы**: получаем real-time данные.
- **Минусы**: требует Pro Live Plan (~1000€/мес), не помогает с REST-лимитом.
- **Вердикт**: не решает основной проблемы.

## Decision Details

### Архитектура L3

```
                  ┌────────────────────────────┐
                  │   Cloud Function (Node)    │
                  │   refreshTournamentsCache  │
                  │   cron: каждые 30с/5м/1ч   │
                  └─────────────┬──────────────┘
                                │
                                ▼
                       PandaScore API
                       (один ключ, низкий QPS)
                                │
                                ▼
                       Firestore collections:
                       └── tournaments_cache/{game}/{segment}
                       └── matches_cache/{game}/lives
                       └── matches_cache/{game}/{segment}

           ▲ читают                              ▲ читают
   ┌───────┴──────┐                      ┌───────┴──────┐
   │   iPhone A   │                      │   iPhone B   │
   └──────────────┘                      └──────────────┘
```

### Что в L3
- Список running/upcoming/past турниров по CS2 и Dota 2 (топ-20 по tier).
- Список live матчей.

### Что НЕ в L3
- Детали конкретного турнира (long-tail, fetch on demand).
- Детали конкретного матча.
- Команды и игроки (low-frequency reads).

Для деталей клиент идёт напрямую в PandaScore через L1/L2.

### Cron расписание

| Endpoint | Cron |
|---|---|
| running tournaments по игре | каждые 5 минут |
| upcoming tournaments | каждые 30 минут |
| past tournaments | раз в час |
| /lives | каждые 30 секунд (или минуту, чтобы экономить функции) |

Итого ~120 invocations в час на функцию, ~3000/сутки, ~90K/месяц. Хорошо вписывается в free-tier Cloud Functions (2M/мес).

### Стоимость
- **Firestore reads**: 50K free/day. На 1000 DAU при 5 чтениях из L3/день = 5K reads/day. Free.
- **Cloud Functions invocations**: ~90K/мес. Free (2M cap).
- **PandaScore запросы**: ~3000/сутки. Глубоко в лимите.
- **Хостинг функций**: 0€ в free-tier.

При росте до 10K DAU — может потребоваться доплата за Firestore reads. Прогнозный budget: до 10-20$/мес. Сильно дешевле PandaScore Pro.

## Consequences

### Положительные
- ✅ Снимаем основной risk превышения лимита PandaScore.
- ✅ Используем уже подключённый Firebase.
- ✅ Низкая стоимость на текущей и среднесрочной аудитории.
- ✅ Single source of truth для всех клиентов — нет inconsistency между устройствами.
- ✅ Можем добавить бизнес-логику в Cloud Function (фильтрация, нормализация) если понадобится.

### Отрицательные
- ❌ Требует написания Cloud Functions (TypeScript / Node) — отдельный стек.
- ❌ Lag между обновлением в PandaScore и доставкой клиенту = TTL функции (макс 30 сек для лайва).
- ❌ Нужно настроить Firestore security rules, чтобы клиенты могли читать кэш, но не писать.
- ❌ Появляется зависимость от Firebase uptime.

### Митигации
- Cloud Functions написать с retry и логированием в Firebase Crashlytics.
- Если Firestore недоступен — клиент fallback'ает на L2/L1 без видимых изменений.
- Если PandaScore вернул 429 в Cloud Function — функция логирует, но **не падает**, оставляя предыдущий кэш.

## Implementation Plan

### Phase 1 (когда):
1. Поднять Cloud Functions project в Firebase.
2. Написать `refreshTournamentsCache` функцию с cron.
3. Настроить Firestore security rules.
4. Добавить `FirestoreTournamentsCache` source на клиенте.
5. Включить L3 чтение в `TournamentsService`.
6. Мониторить логи Cloud Functions и `tournaments_rate_limited` event.

### Откат
Если что-то сломается — можно временно отключить L3 в `TournamentsService` (флаг в `RemoteConfig` или код-фикс). Клиент продолжит работать на L1+L2 + прямой PandaScore.

## Follow-ups

- Future ADR: если PandaScore Pro подключим, пересмотреть нужность L3 (возможно, упрощённая версия).
- Future ADR: если DAU > 10K, рассмотреть Cloudflare Workers как edge-кэш.

---

_Last updated: 2026-05-25_
