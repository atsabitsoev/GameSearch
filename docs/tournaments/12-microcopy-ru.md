# 12 — Microcopy (RU)

Все строки на русском, которые показывает модуль. **Источник истины** — добавлять новые строки сюда, потом ссылаться в коде.

Когда дойдём до Phase 4 (локализация EN) — переедет в `Localizable.strings`. Сейчас храним константы прямо в Swift (например `enum TournamentsStrings`).

---

## Стиль текста

- **Прямой и краткий.** «Идёт сейчас» лучше «В данный момент происходит».
- **На «ты».** Это приложение для своих, не корпоративный продукт. «Подпишись», «Получай».
- **Без восклицательных знаков и эмоций.** Кроме приветственного onboarding.
- **Числа — арабские.** «За 15 минут», не «За пятнадцать минут».
- **Даты сокращённо.** «21 мар» — да; «21 марта 2026 года» — нет.
- **Эмодзи разрешены умеренно** — в onboarding и кнопках, не в данных.

---

## Tab title

| Ключ | Текст |
|---|---|
| `tournaments_tab_title` | `Турниры` |

---

## TournamentsListView — Список

| Ключ | Текст |
|---|---|
| `tournaments_nav_title` | `Турниры` |
| `tournaments_segment_running` | `Сейчас` |
| `tournaments_segment_upcoming` | `Скоро` |
| `tournaments_segment_past` | `Прошедшие` |
| `tournaments_segment_my` | `Мои` (Phase 1) |
| `tournaments_game_cs2` | `CS2` |
| `tournaments_game_dota2` | `Dota 2` |
| `live_strip_title` | `Сейчас идёт` |
| `live_strip_view_all` | `Все live →` (опционально) |
| `tournaments_pull_to_refresh` | (системный) |
| `tournaments_search_placeholder` | `Поиск турниров` (Phase 1) |
| `tournaments_filter_button` | `Фильтры` (Phase 1) |

### Empty states

| Ключ | Текст |
|---|---|
| `empty_running_title` | `Сейчас никто не играет` |
| `empty_running_subtitle` | `Загляни в раздел «Скоро»` |
| `empty_upcoming_title` | `Ничего не запланировано` |
| `empty_upcoming_subtitle` | `Загляни позже — расписание обновится` |
| `empty_past_title` | `Нет прошедших турниров` |
| `empty_past_subtitle` | `Видимо, мы ещё не начали` |
| `empty_search_title` | `Ничего не нашли` |
| `empty_search_subtitle` | `Попробуй другое название` |
| `empty_favorites_title` | `Тут будут твои подписки` |
| `empty_favorites_subtitle` | `Подпишись на команду, турнир или игрока` |

### Error states

| Ключ | Текст |
|---|---|
| `error_no_internet_title` | `Нет интернета` |
| `error_no_internet_subtitle` | `Проверь соединение и попробуй ещё раз` |
| `error_temporary_title` | `Турниры временно недоступны` |
| `error_temporary_subtitle` | `Это с нашей стороны. Уже чиним.` |
| `error_retry_button` | `Повторить` |

---

## TournamentDetailsView — Детали турнира

| Ключ | Текст |
|---|---|
| `tournament_details_nav_title_fallback` | `Турнир` |
| `tournament_tab_matches` | `Матчи` |
| `tournament_tab_standings` | `Таблица` |
| `tournament_tab_brackets` | `Сетка` |
| `tournament_tab_participants` | `Команды` |
| `tournament_prize_label` | `Призовой` |
| `tournament_dates_separator` | ` — ` |
| `tournament_brackets_coming_soon_title` | `Сетка скоро появится` |
| `tournament_brackets_coming_soon_subtitle` | `Над сеткой плей-офф ещё работаем` |
| `tournament_share_button` | `Поделиться` |
| `tournament_favorite_button` | `В избранное` |
| `tournament_favorited_button` | `В избранном` |

### Stage labels (динамические, форматирование)

| Контекст | Формат |
|---|---|
| Группа | `Group A`, `Group B` (как приходит из API) |
| Плей-офф | `Playoffs` |
| Финал | `Grand Final` |
| Иное | Как пришло из `name` поля турнира |

### Standings table header

| Ключ | Текст | Источник данных |
|---|---|---|
| `standings_col_rank` | `#` | `Standing.rank` |
| `standings_col_team` | `Команда` | `Standing.team.name` |
| `standings_col_wins` | `В` | `Standing.wins` (PandaScore wins, только group/Swiss) |
| `standings_col_losses` | `П` | `Standing.losses` |
| `standings_col_total` | `Игр` | `Standing.total` (= wins+losses+ties) |
| `standings_col_maps` | `Карты` | `"{gameWins}-{gameLosses}"` |
| `standings_col_points` | `Очки` | `Standing.points` (legacy для не-CS игр) |

Колонки отрисовываются только если у хотя бы одной строки есть соответствующее значение (`StandingsColumnLayout`). Для playoff-bracket таблица деградирует до `# | Команда`.

### Participants tab

| Ключ | Текст |
|---|---|
| `participants_section_title` | `Команды-участники` |
| `participants_roster_label` | `Состав` |
| `participants_no_roster` | `Состав не объявлен` |
| `participants_empty_title` | `Команды ещё не объявлены` (Phase 1.B — когда `participants == nil/[]`) |
| `participants_empty_subtitle` | `Список появится ближе к старту` |

### Standings tab — empty state

| Ключ | Текст |
|---|---|
| `standings_empty_title` | `Таблицы пока нет` (Phase 1.B — резерв на случай если API вернёт пустой список) |
| `standings_empty_subtitle` | `Появится после первых матчей` |

### Matches tab — empty state

| Ключ | Текст |
|---|---|
| `matches_empty_title` | `Расписание ещё не готово` (резерв; в коде сейчас переиспользуется `empty_upcoming_*`) |
| `matches_empty_subtitle` | `Появится ближе к старту` |

---

## MatchDetailsView — Детали матча

| Ключ | Текст |
|---|---|
| `match_details_nav_title` | `Матч` |
| `match_format_bo3` | `BO3` |
| `match_format_bo5` | `BO5` |
| `match_format_bo1` | `BO1` |
| `match_status_live` | `LIVE` |
| `match_status_finished` | `Завершён` |
| `match_status_canceled` | `Отменён` |
| `match_status_postponed` | `Перенесён` |
| `match_status_not_started` | (показываем время вместо счёта) |
| `match_section_maps` | `Карты` |
| `match_section_games` | `Игры` (для Dota 2) |
| `match_section_streams` | `Где смотреть` |
| `match_section_rosters` | `Составы` |
| `match_map_not_started` | `Не начато` |
| `match_no_streams_title` | `Стримов пока нет` |
| `match_no_streams_subtitle` | `Появятся ближе к началу` |
| `match_share_button` | `Поделиться` |

### Stream platforms

| Платформа | Лейбл |
|---|---|
| Twitch | `Twitch` |
| YouTube | `YouTube` |
| Другое | `Веб` |

### Action labels на стримах

| Ключ | Текст |
|---|---|
| `stream_open_twitch` | `Открыть в Twitch` |
| `stream_open_youtube` | `Открыть в YouTube` |
| `stream_open_safari` | `Открыть в Safari` |
| `stream_official_badge` | `Официальный` |
| `stream_main_badge` | `Главный` |

---

## TeamProfileView (Phase 2)

| Ключ | Текст |
|---|---|
| `team_section_roster` | `Состав` |
| `team_section_recent_matches` | `Последние матчи` |
| `team_no_recent_matches` | `Нет данных о матчах` |
| `team_favorite_added_toast` | `Команда добавлена в избранное` |
| `team_favorite_removed_toast` | `Команда удалена из избранного` |

---

## PlayerProfileView (Phase 2)

| Ключ | Текст |
|---|---|
| `player_section_info` | `Информация` |
| `player_label_team` | `Команда` |
| `player_label_role` | `Роль` |
| `player_label_game` | `Игра` |
| `player_label_country` | `Страна` |
| `player_label_age` | `Возраст` |
| `player_age_years` | `лет` (для согласования: «35 лет», но «1 год», «3 года» — учитывать множественное число) |
| `player_active_yes` | `Активен` |
| `player_active_no` | `Неактивен` |

---

## Favorites (Phase 1)

| Ключ | Текст |
|---|---|
| `favorites_section_teams` | `Команды` |
| `favorites_section_tournaments` | `Турниры` |
| `favorites_section_players` | `Игроки` |
| `favorites_next_match_in` | `Следующий матч через %@` (где %@ = «2 ч», «15 мин», «завтра в 18:00») |
| `favorites_no_upcoming` | `Ближайших матчей нет` |
| `favorites_tournament_day` | `День %d из %d` |

---

## Onboarding (Phase 1)

| Ключ | Текст |
|---|---|
| `onboarding_page_1_title` | `Следи за турнирами` |
| `onboarding_page_1_subtitle` | `CS2 и Dota 2 в одном месте. Расписания, результаты, стримы.` |
| `onboarding_page_2_title` | `Не пропускай матчи` |
| `onboarding_page_2_subtitle` | `Подпишись на команду — пришлём уведомление за 15 минут до матча.` |
| `onboarding_cta_next` | `Дальше` |
| `onboarding_cta_done` | `Понятно` |

---

## Spoiler (Phase 3)

| Ключ | Текст |
|---|---|
| `spoiler_hint_title` | `Прячем счёт, чтобы не спойлерить` |
| `spoiler_hint_subtitle` | `Можно отключить в настройках` |
| `spoiler_hint_action_ok` | `Понятно` |
| `spoiler_reveal_hint` | `Тапни, чтобы показать` |
| `settings_spoiler_free_label` | `Скрывать счёт прошедших матчей` |

---

## Push notifications (Phase 1)

| Тип | Заголовок | Тело |
|---|---|---|
| Match starting soon | `Скоро матч %@` (team) | `Через %@ — %@ vs %@` (time, team1, team2) |
| Match finished | `%@ vs %@ — %@` (team1, team2, score) | `Финал %@` (tournament name) |
| Tournament playoffs | `Плей-офф %@ начался` (tournament) | `Загляни — кто прошёл, кто вылетел` |
| Favorite team plays today | `Сегодня играет %@` (team) | `Матч в %@ vs %@` (time, opponent) |

### Permission request

| Ключ | Текст |
|---|---|
| `push_permission_title` | `Напомним, когда заиграет любимая команда` |
| `push_permission_subtitle` | `Включи уведомления — пришлём пуш за 15 минут до матча` |
| `push_permission_allow` | `Включить уведомления` |
| `push_permission_later` | `Не сейчас` |

---

## Settings (Phase 3)

| Ключ | Текст |
|---|---|
| `settings_tournaments_section` | `Турниры` |
| `settings_spoiler_free_label` | `Спойлер-фри режим` |
| `settings_default_game_label` | `Игра по умолчанию` |
| `settings_quiet_hours_label` | `Тихие часы для уведомлений` |
| `settings_quiet_hours_from` | `С` |
| `settings_quiet_hours_to` | `До` |

---

## Toasts и confirmations

| Действие | Toast |
|---|---|
| Добавлено в избранное | `Добавили в избранное` |
| Удалено из избранного | `Убрали из избранного` |
| Скопирован deeplink | `Ссылка скопирована` |
| Не удалось открыть стрим | `Не получилось открыть стрим` |
| Включены push | `Готово, будем уведомлять` |
| Уже подписан | `Уже в избранном` |

---

## Существующий placeholder (оставить как fallback)

Эти строки уже есть в `TournamentsPlaceholderView.swift`. **Не менять формулировки** без сохранения backwards-compat (используются в AppMetrica логике).

| Ключ | Текст |
|---|---|
| `placeholder_hero_title` | `Скоро турниры` |
| `placeholder_hero_subtitle` | `Здесь будут профессиональные турниры, матчи и стримы, чтобы удобно следить за киберспортом` |
| `placeholder_first_in_list_label` | `Первые в списке:` |
| `placeholder_loading_tournaments` | `Получаем турниры...` |
| `placeholder_hint` | `Хочешь узнать об обновлении первым?` |
| `placeholder_cta` | `Да хочу!` |
| `placeholder_toast` | `Окей, уведомим тебя первым` |

---

## Форматирование дат и времени

| Контекст | Формат | Пример |
|---|---|---|
| Дата на карточке | `d MMM` (ru) | `21 мар` |
| Диапазон дат | `d MMM — d MMM` | `21 мар — 31 мар` |
| Время матча (сегодня) | `HH:mm` | `15:00` |
| Время матча (завтра) | `завтра в HH:mm` | `завтра в 15:00` |
| Время матча (далеко) | `d MMM, HH:mm` | `5 июн, 15:00` |
| Время до матча | `через H ч M мин` или `через M мин` | `через 2 ч 15 мин`, `через 15 мин` |
| Полная дата + год (Header) | `d MMMM yyyy` | `21 марта 2026` |
| Время прошедшего матча | `d MMM в HH:mm` или `вчера в HH:mm` | `вчера в 15:00`, `5 июн в 15:00` |

Используем `DateFormatter` с `locale = Locale(identifier: "ru_RU")` и `RelativeDateTimeFormatter` для «через X минут».

Базовые относительные слова (для лекс. согласования с другими временными строками):

| Ключ | Текст |
|---|---|
| `time_today` | `Сегодня` |
| `time_tomorrow` | `Завтра` |
| `time_yesterday` | `Вчера` |

Реализация (Phase 1.B): `Shared/MatchTimeFormatter.swift` — статический enum с методами `upcoming(_:)`, `finished(_:)`, `clock(_:)`. Все используют общий cached `DateFormatter` с `ru_RU` локалью.

---

## Форматирование чисел

| Контекст | Формат | Пример |
|---|---|---|
| Призовой (большой) | `$X.XM` | `$1.25M` |
| Призовой (средний) | `$XK` | `$850K` |
| Призовой (маленький) | `$X,XXX` | `$5,000` |
| Призовой без валюты | `X XXX XXX` | `1 250 000` |
| Возраст | `X лет/года/год` (склонение) | `35 лет`, `21 год`, `23 года` |

Реализация склонений — через `Foundation` plural rules или вручную в `PrizepoolFormatter` / `AgeFormatter`.

---

_Last updated: 2026-05-25 (Phase 1.B — добавлены empty states для Standings/Participants/Matches табов, базовые «Сегодня/Завтра/Вчера»)_
