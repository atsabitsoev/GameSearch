# Tournaments Module — Knowledge Base

База знаний по модулю «Турниры» приложения **GameSearch (iOS)**.

Цель этой папки — дать любому разработчику или AI-агенту в любом новом чате полный контекст, необходимый для качественной разработки модуля без потерь информации между сессиями.

> **Если ты AI-агент и впервые видишь этот проект** — прочитай сначала `00-context-for-agents.md`. Это твоя точка входа. Дальше — по ссылкам по мере необходимости.

> **Если ты человек-разработчик** — начни с `01-vision-and-scope.md`, потом `15-roadmap.md`, дальше по интересу.

---

## Структура

```
docs/tournaments/
├── README.md                          ← ты здесь
├── 00-context-for-agents.md           ← MUST READ для нового чата агента
│
├── 01-vision-and-scope.md             ← зачем, для кого, чего НЕ делаем
├── 02-features-matrix.md              ← MVP / Phase 2 / Won't-do
├── 03-competitors.md                  ← HLTV, Liquipedia, Spectra, Escores
│
├── 04-pandascore-api.md               ← всё про API: эндпоинты, лимиты, биллинг
│
├── 05-architecture.md                 ← слои, потоки данных, диаграмма
├── 06-data-models.md                  ← Swift domain-модели
├── 07-caching-strategy.md             ← кэш L1/L2/L3 + Firestore-прокси
├── 08-modules-and-files.md            ← файловая структура модуля
│
├── 09-ux-principles.md                ← правила UX в нашем приложении
├── 10-screens.md                      ← описание всех экранов + ASCII wireframes
├── 11-design-system.md                ← EAColor, EAFont, переиспользуемые компоненты
├── 12-microcopy-ru.md                 ← все строки на русском
│
├── 13-analytics.md                    ← события AppMetrica
├── 14-deeplinks.md                    ← URL-схемы и роутинг
│
├── 15-roadmap.md                      ← этапы разработки и критерии готовности
├── 16-coding-conventions.md           ← конвенции в этом проекте
├── 17-testing.md                      ← стратегия тестирования
│
└── decisions/                         ← Architecture Decision Records (ADR)
    ├── ADR-001-pandascore-as-data-source.md
    ├── ADR-002-backend-cache-via-firestore.md
    ├── ADR-003-streams-as-deeplink.md
    ├── ADR-004-launch-with-cs2-dota2-only.md
    └── ADR-005-no-betting-no-fantasy.md
```

---

## Принципы поддержки этой документации

1. **Single source of truth.** Если решение принято — оно живёт в одном файле. Дублирование запрещено, лучше ссылаться.
2. **ADR не редактируется.** Решения остаются как исторический контекст. Если решение пересмотрено — создаётся новая ADR со ссылкой `Supersedes: ADR-XXX`.
3. **Roadmap — живой документ.** Чек-боксы и статусы обновляются по мере прогресса.
4. **Features Matrix синхронизирована с Roadmap.** Если фича переехала из Phase 2 в MVP — обновляются оба файла.
5. **Дата последнего изменения** проставляется в конце каждого файла как `_Last updated: YYYY-MM-DD_`. Это помогает агентам понять, насколько свежий контекст.

---

## Связанные документы вне этой папки

- `/AGENTS.md` — общие правила для AI-агентов по проекту (MCP, симулятор, дебаг).
- `/GameSearch/Services/Tournaments/` — текущая реализация (placeholder).
- `/GameSearch/Modules/Tournaments/` — UI текущей заглушки.

---

_Last updated: 2026-05-25_
