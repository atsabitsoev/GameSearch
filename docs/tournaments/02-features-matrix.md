# 02 — Features Matrix

Полная матрица возможностей модуля «Турниры». Колонка **Status** обновляется по мере прогресса.

Легенда:
- `MVP` — обязательно в первом релизе модуля
- `P1` — Phase 1 после MVP (избранное, push)
- `P2` — Phase 2 (профили команд/игроков)
- `P3` — Phase 3 (polish, расширение)
- `Future` — рассмотрим после набора аудитории
- `Won't do` — явно не делаем (см. причину)

---

## Списки и навигация

| Feature | Phase | Description | Status |
|---|---|---|---|
| Таб «Турниры» в TabBar | MVP | Уже есть в `TabTag.swift`. Меняем content с placeholder на полноценный | partial |
| Список турниров с сегментами `Сейчас / Скоро / Прошедшие` | MVP | Source: `/{game}/tournaments/{running\|upcoming\|past}` | not started |
| Фильтр по игре (CS2 / Dota 2) | MVP | Сегмент-контрол сверху | not started |
| Pagination 20 → 20 → ... | MVP | `page[size]=20`, infinity scroll | not started |
| Поиск по названию турнира | P1 | `search[name]=` | not started |
| Sticky-блок «Сейчас идёт» (Live Strip) | MVP | Горизонтальный скролл live-матчей наверху списка | not started |
| Pull-to-refresh | MVP | Сброс кэша L1/L2 для текущего сегмента | not started |
| Skeleton loading | MVP | Аналогично `ArticlesSkeletonCard` | not started |
| Empty state | MVP | Когда фильтр ничего не дал — переиспользуем placeholder-UI | not started |
| Error state (нет интернета) | MVP | Заглушка + кнопка повтор | not started |

## Детали турнира

| Feature | Phase | Description | Status |
|---|---|---|---|
| Экран `TournamentDetailsView` | MVP | `/tournaments/{id_or_slug}` | not started |
| Хедер: лого лиги, название, серия, даты, призовой фонд | MVP | Все поля из ответа | not started |
| Tier-бейдж (S/A/B) | MVP | Цветовая дифференциация | not started |
| Вкладки: Матчи / Таблица / Сетка / Команды | MVP | Через `SwipeSegmentedView` | not started |
| Таблица результатов (Standings) | MVP | `/tournaments/{id}/standings` | not started |
| Сетка плей-офф (Brackets) | P1 | `/tournaments/{id}/brackets` — сложный UI | not started |
| Список матчей с группировкой по стадиям | MVP | Группы / Playoffs / Grand Final | not started |
| Список команд-участников с ростерами | MVP | `expected_roster` из ответа турнира | not started |
| Кнопка «Share» (deeplink) | P1 | Native share sheet | not started |
| Кнопка «Добавить в избранное» | P1 | См. секцию Favorites | not started |

## Детали матча

| Feature | Phase | Description | Status |
|---|---|---|---|
| Экран `MatchDetailsView` | MVP | `/matches/{id}` | not started |
| Хедер: команды, BoX, статус, время, турнир | MVP | | not started |
| Live-индикатор для running матчей | MVP | Пульсирующая точка | not started |
| Счёт по картам / играм | MVP | `games` массив из ответа | not started |
| Для CS2: название карты на каждую игру | MVP | `map.name` | not started |
| Ростеры обеих команд | MVP | `opponents[].players` | not started |
| Список стримов с языком и платформой | MVP | `streams_list` | not started |
| Тап на стрим → Twitch.app / YouTube.app | MVP | Через `UIApplication.shared.open` | not started |
| Spoiler-free toggle | P3 | Тогл в Settings + скрытие счёта | not started |
| Head-to-head история команд | Future | Требует доп. запросов, сложно сделать быстро | won't do |

## Профили (Phase 2)

| Feature | Phase | Description | Status |
|---|---|---|---|
| Профиль команды | P2 | `/{game}/teams/{id}` | not started |
| Ростер команды | P2 | | not started |
| Последние 10 матчей команды | P2 | `/teams/{id}/matches` | not started |
| Профиль игрока | P2 | `/{game}/players/{id}` | not started |
| Базовая статистика игрока | P2 | Free-tier dataset | not started |
| Расширенная статистика (KDA, K/D) | Future | Требует Pro / Historical plan | won't do |
| Карьерный путь игрока (история команд) | Future | Очень специфично | won't do |

## Избранное и уведомления (Phase 1)

| Feature | Phase | Description | Status |
|---|---|---|---|
| Подписка на команду | P1 | Хранение: локально + Firestore (anonymous uid) | not started |
| Подписка на турнир | P1 | | not started |
| Подписка на игрока | P2 | | not started |
| Вкладка «Мои» в табе турниров | P1 | Группировка избранных | not started |
| Push: «Матч твоей команды через 15 минут» | P1 | Бэкенд-планировщик + FCM | not started |
| Push: «Команда сыграла — результат» | P1 | | not started |
| Push: «Начался плей-офф турнира» | P1 | | not started |
| Quiet hours для push | P3 | В Settings | not started |
| In-app notifications center | Future | Сложно, мало value | won't do |

## Стримы и видео

| Feature | Phase | Description | Status |
|---|---|---|---|
| Список стримов в детали матча | MVP | `streams_list` | not started |
| Deeplink → Twitch.app | MVP | URL scheme `twitch://stream/<channel>` с fallback на Safari | not started |
| Deeplink → YouTube.app | MVP | YouTube App URL | not started |
| Встроенный плеер Twitch в WKWebView | Won't do | См. ADR-003. Хуже UX, недели поддержки | won't do |
| VOD-архив | Won't do | Не в free-плане, отдельный модуль | won't do |
| Подсказки «где смотреть» (RU-стримы) | P3 | Сортировка по language=ru | not started |

## UX-улучшения (Phase 3)

| Feature | Phase | Description | Status |
|---|---|---|---|
| Spoiler-free mode | P3 | Глобальный тогл в Settings | not started |
| Анимации перехода между экранами | P3 | Matched geometry effect | not started |
| Haptic feedback на ключевые действия | P3 | UIImpactFeedbackGenerator | not started |
| Dark accent theme per game (CS2 жёлтый, Dota красный) | P3 | Уже есть `csColor` и `dotaColor` | partial |
| Эмодзи-флаги стран | P3 | На команды и игроков | not started |
| Pull-down вместо modal для фильтров | P3 | Native iOS feel | not started |

## Расширение (Future)

| Feature | Phase | Description | Status |
|---|---|---|---|
| Поддержка LoL | Future | После стабильного MVP | not started |
| Поддержка Valorant | Future | | not started |
| Поддержка R6 | Future | | not started |
| iOS Widget «Сегодня играет» | Future | Высокий UX-impact | not started |
| Live Activities (Dynamic Island) | Future | Для running матчей с избранной командой | not started |
| Apple Watch companion | Future | Только результаты | won't do |
| iPadOS оптимизация | Future | Sidebar layout | not started |

## Won't do (с обоснованием)

| Feature | Почему нет |
|---|---|
| Коэффициенты, прогнозы, ставки | Запрещено лицензией PandaScore Free; высокий регуляторный риск |
| Фэнтези-лиги | Отдельный большой продукт |
| Чат под матчами | Модерация = постоянный сервисный долг |
| Встроенный плеер стримов | Хуже UX, постоянные ломки SDK |
| VOD-архив | Pro-only, сложно поддерживать |
| In-game live stats (kills/gold timeline) | Pro Live Plan от 1000€/мес |
| Свой парсинг HLTV/Liquipedia | Юридически серо, технически хрупко |
| Apple Watch companion | Низкий ROI, мало пересечения с use case |
| Подкасты / новости (если в News не покрыто) | Уже есть таб News |

---

_Last updated: 2026-05-25_
