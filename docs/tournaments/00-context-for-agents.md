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
- `GameSearch/Services/Tournaments/PandaScoreTournamentsService.swift` — дёргает PandaScore и берёт название первого running/upcoming турнира для CS2 и Dota 2. Кэш в `UserDefaults` на 10 минут.
- `GameSearch/Modules/Tournaments/TournamentsPlaceholderView.swift` — заглушка с двумя карточками и кнопкой «Да хочу!» (AppMetrica event).
- `Router/TabTag.swift` — таб `.tournaments` уже зарегистрирован.
- `Factory/ScreenFactory.makeTournamentsView()` — отдаёт placeholder.
- `Routes.swift` — для турниров маршрутов **нет**, добавляем при работе.

**Важно**: placeholder НЕ удаляем, превращаем в empty/error-state — см. `10-screens.md`.

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

_Last updated: 2026-05-25_
