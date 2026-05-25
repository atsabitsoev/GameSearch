# 11 — Design System

Точная справка по дизайн-системе GameSearch применительно к модулю турниров. Все имена цветов и шрифтов — реальные из проекта (`EAColor.swift`, `EAFont.swift`).

---

## Цветовая палитра (EAColor)

Все цвета определены в `GameSearch/EAColor.swift` через `Color("AssetName")`. Используем **только их**.

### Backgrounds

| Token | Asset | Использование |
|---|---|---|
| `EAColor.background` | `BackgroundColor` | Основной фон экрана |
| `EAColor.secondaryBackground` | `SecondaryBackgroundColor` | Фон карточек, секций |

### Text

| Token | Asset | Использование |
|---|---|---|
| `EAColor.textPrimary` | `TextPrimary` | Заголовки, основной текст |
| `EAColor.textSecondary` | `TextSecondary` | Подзаголовки, captions, disabled |

### Game accents

| Token | Asset | Использование |
|---|---|---|
| `EAColor.csColor` | `csColor` | Всё связанное с CS2 (бейджи, обводки) |
| `EAColor.dotaColor` | `dotaColor` | Всё связанное с Dota 2 |

### Semantic accents

| Token | Asset | Использование |
|---|---|---|
| `EAColor.purpleAccent` | `PurpleAccentColor` | Главные CTA, tier S, акценты |
| `EAColor.accent` | `AccentColor` | Глобальный accent (системный) |
| `EAColor.accentGradient` | `AccentGradientColor` | Градиент-пары с `purpleAccent` |
| `EAColor.yellow` | `YellowColor` | Призовой фонд, победитель, важные числа |
| `EAColor.orange` | `OrangeColor` | Live-индикатор (или Color.red) |
| `EAColor.info1` | `Info1Color` | Информационные блоки 1 |
| `EAColor.info2` | `Info2Color` | Информационные блоки 2, tier A |
| `EAColor.infoMain` | `InfoMainColor` | Главные info-блоки |

### Использование по компонентам модуля

| Component | Background | Text | Accent |
|---|---|---|---|
| Screen background | `EAColor.background` | — | — |
| `TournamentCard` | `EAColor.secondaryBackground` | `textPrimary` для названия, `textSecondary` для деталей | tier-badge через `Tier.color` |
| `LiveMatchChip` | `EAColor.secondaryBackground` | `textPrimary` | `Color.red` (Live dot) |
| `TierBadge` (S) | `EAColor.purpleAccent.opacity(0.18)` | `purpleAccent` | `purpleAccent` border |
| `TierBadge` (A) | `EAColor.info2.opacity(0.18)` | `info2` | `info2` border |
| `TierBadge` (B/C/D) | `EAColor.secondaryBackground` | `textSecondary` | `textSecondary` border |
| `LiveBadge` | пульсирующая `Color.red` | `textPrimary` | — |
| `ScoreView` winner | `EAColor.yellow.opacity(0.15)` | `EAColor.yellow` | — |
| `ScoreView` loser | прозрачный | `textSecondary` | — |
| Main CTA button | linear gradient `[purpleAccent.opacity(0.95), purpleAccent.opacity(0.45)]` | `textPrimary` | — |
| Secondary button | `secondaryBackground` | `textPrimary` | `textPrimary.opacity(0.2)` border |

### Запреты по цвету

- ❌ Не использовать `.black`, `.white`, `.gray` напрямую. Только через `EAColor`.
- ❌ Не создавать локальные `Color(red:green:blue:)` в коде модуля.
- ❌ Не использовать системные `Color.accentColor` — у нас свой `EAColor.accent`.
- ✅ `Color.red` для Live-индикатора — допустимо (это семантический primary-цвет статуса).

---

## Типографика (EAFont)

Шрифт основной — **Helvetica** во всех начертаниях. Все размеры определены в `GameSearch/EAFont.swift`.

### Таблица

| Token | Font | Size | Использование в модуле |
|---|---|---|---|
| `EAFont.blackTitle` | Helvetica-Black | 24 | Не используется в модуле (специальный) |
| `EAFont.title` | Helvetica-Bold | 24 | Главные заголовки на full-screen onboarding |
| `EAFont.header` | Helvetica-Bold | 20 | Заголовки секций, header детальных экранов |
| `EAFont.infoBig` | Helvetica | 18 | Большие тексты в info-блоках |
| `EAFont.infoTitle` | Helvetica-Bold | 18 | Названия турниров, имена команд в header |
| `EAFont.infoTitleMedium` | Helvetica | 18 | Подзаголовки секций |
| `EAFont.smallTitle` | Helvetica-Medium | 16 | Названия в карточках, имена команд в строках |
| `EAFont.info` | Helvetica | 14 | Основной текст карточек, описания |
| `EAFont.infoBold` | Helvetica-Bold | 14 | Подсвеченные элементы (счёт, призовой) |
| `EAFont.description` | Helvetica | 12 | Captions, time labels |
| `EAFont.infoSmall` | Helvetica | 10 | Badges текст (tier, country code) |
| `EAFont.navigationBarTitle` | Helvetica-Bold | 17 | Системно для NavBar |

### Семантическая карта (что где)

| Element | Font |
|---|---|
| Tab title `"Турниры"` | `EAFont.navigationBarTitle` (системно) |
| Header `"Сейчас идёт"` | `EAFont.header` |
| Tournament name на карточке | `EAFont.smallTitle` |
| Tournament details (даты + призовой) | `EAFont.info` |
| Team name в карточке матча | `EAFont.smallTitle` |
| Score `"1 — 0"` | `EAFont.infoBold` |
| Score winner highlighted | `EAFont.infoBold` (color: `EAColor.yellow`) |
| Tier badge text `"S"` | `EAFont.infoSmall` |
| Country flag emoji + code | `EAFont.description` |
| Live `"LIVE"` text | `EAFont.infoSmall` |
| Caption `"BO5 · 15:00"` | `EAFont.description` |
| Player nickname | `EAFont.smallTitle` |
| Player full name (Finn Andersen) | `EAFont.description` |

### Запреты по типографике

- ❌ Не использовать `Font.system(...)` или `Font.title2`.
- ❌ Не задавать `.font(.system(size: 18))` напрямую.
- ✅ Можно `.fontWeight(.medium)` для модификации существующего EAFont только в редких случаях.

---

## Spacing

Используем кратные **4 pt**:

| Token | Value | Использование |
|---|---|---|
| `xs` | 4 | Между связанными элементами (значок + текст) |
| `s` | 8 | Между близкими элементами в карточке |
| `m` | 12 | Базовый padding карточек, gap между мелкими карточками |
| `l` | 16 | Горизонтальный padding экрана, vertical gap между секциями |
| `xl` | 20 | Между крупными группами |
| `xxl` | 24 | Top-padding экрана |
| `xxxl` | 32 | Большие разделители |

В коде — просто числа, без enum. Например `.padding(.horizontal, 16)`.

> При добавлении нового spacing в дизайне — сначала проверь существующие отступы в `ClubListView` / `ArticlesListView`. Если есть похожее — используй то же значение.

---

## Corner radius

| Element | Radius |
|---|---|
| Карточки списка (TournamentCard) | `12` |
| Кнопки primary | `12` |
| Бейджи (Tier, Live, Country) | `4` или `6` |
| Карточки большие (Header) | `16` |
| Аватары команд / игроков в списке | half (= circle) |
| Аватары в Header | `12` |
| Skeleton placeholder | `8` |

Стиль — всегда `.continuous` (`RoundedRectangle(cornerRadius: 12, style: .continuous)`).

---

## Тени

В тёмной теме тени почти не работают — используем border-обводки.

| Element | Border |
|---|---|
| TournamentCard | без обводки |
| TierBadge | `.stroke(color.opacity(0.55), lineWidth: 1)` |
| Selected segment | `.stroke(EAColor.purpleAccent, lineWidth: 1)` |
| LiveBadge | без обводки, только заливка |

---

## Переиспользуемые компоненты проекта

Прежде чем создавать новый View — проверь существующие.

### Из текущего проекта

| Component | Path | Что делает | Где используем |
|---|---|---|---|
| `SwipeSegmentedView` | `Modules/Clubs/ClubDetailsView/Views/SectionPicker/SwipeSegmentedView.swift` | Сегмент-контрол + свайпаемые табы | `TournamentDetailsView` для табов Матчи/Таблица/Сетка/Команды |
| `RadioButton` | `Modules/Clubs/ClubDetailsView/Views/Specs/RadioButton.swift` | Radio-кнопка | — (не нужно в модуле турниров) |
| `LocationLabel` | `UIKit/LocationLabel.swift` | Лейбл с pin-иконкой | Можно использовать для страны в header турнира |
| `ExpandableText` | `UIKit/ExpandableText.swift` | Текст с раскрытием | Не нужно в MVP |
| `ZoomAndPanImage` | `UIKit/ZoomAndPanImage.swift` | Изображение с pinch-zoom | Не нужно в модуле турниров |
| `ArticlesSkeletonCard` | `Modules/Articles/ArticlesList/Views/ArticlesSkeletonCard.swift` | Skeleton-карточка статьи | Образец для `TournamentsSkeletonCard` |
| `GhostArticlesCell` | `Modules/Articles/Placeholder/Views/GhostArticlesCell.swift` | Placeholder ячейка | Образец для skeleton |

### Из системы (SwiftUI)

| Component | Использование в модуле |
|---|---|
| `AsyncImage` | Логотипы команд, лиг (с fallback gradient + initials) |
| `CachedAsyncImage` (из проекта) | Предпочтительно вместо AsyncImage для логотипов |
| `NavigationStack` + `NavigationPath` | Основа роутинга |
| `List` / `ScrollView` + `LazyVStack` | Списки. Использовать LazyVStack для произвольной вёрстки карточек |
| `ContextMenu` | Long-press действия |
| `ShareLink` | Phase 1 для шеринга турнира/матча |
| `.refreshable {}` | Pull-to-refresh |

### Новые модульные компоненты (которые создаём)

Все живут в `Modules/Tournaments/Shared/`:

| Component | Описание |
|---|---|
| `TierBadge(tier: Tier)` | Цветной бейдж `[S]` / `[A]` |
| `LiveBadge` | Пульсирующая красная точка + текст `LIVE` |
| `TeamLogo(team: Team, size: CGFloat)` | Логотип с fallback-инициалами и градиент-кружком |
| `GameAccentColor` (helper) | Возвращает Color по Game |
| `DateRangeLabel(from: Date, to: Date)` | Форматирует диапазон `"21 мар — 31 мар"` |
| `CountryFlag(code: String)` | Эмодзи флаг из ISO-кода |
| `PrizepoolLabel(prizepool: Prizepool)` | Форматирует `"$1.25M"` |
| `ScoreView(left: Int, right: Int, winner: TeamId?)` | Счёт с подсветкой |
| `SpoilerWrapper(content:)` | Phase 3 — обёртка с возможностью скрытия |

---

## Иконки

- **SF Symbols** для всех иконок UI (кнопки share, back, и т.д.).
- **Asset images** для логотипов игр (`cs2_logo`, `dota2_logo` — добавить в `Assets.xcassets`).
- **Logo команд / лиг** — через URL из PandaScore, `CachedAsyncImage`.
- **Эмодзи флаги** для стран — `🇩🇰 🇷🇺 🇺🇦` (через computed property из ISO-кода).

### Используемые SF Symbols

| Use | Symbol |
|---|---|
| Share | `square.and.arrow.up` |
| Favorite empty | `heart` |
| Favorite filled | `heart.fill` |
| Bell (notifications) | `bell.badge.fill` |
| Live dot | `circle.fill` (вместе с pulse animation) |
| Trophy | `trophy.fill` |
| Calendar | `calendar` |
| Globe (region) | `globe` |
| Refresh | `arrow.clockwise` |
| Back | системный (NavigationStack) |
| Search | `magnifyingglass` (Phase 1) |
| Filter | `slider.horizontal.3` (Phase 1) |
| Settings | `gearshape` |

---

## Composition rules

### Карточка списка

```
┌──────────────────────────────────────────┐  ← cornerRadius 12, fill secondaryBackground
│  16 pt padding                           │
│  ┌──┐                                    │
│  │24│  TITLE (smallTitle, textPrimary)   │  ← 24×24 logo + 12 pt gap
│  │×24│  Subtitle (info, textSecondary)   │
│  └──┘                                    │
│        Caption · Caption (description, textSecondary)
│                                          │
└──────────────────────────────────────────┘
```

### Header детального экрана

```
┌──────────────────────────────────────────┐  ← cornerRadius 16, fill secondaryBackground
│  20 pt padding                           │
│        ┌────┐                            │
│        │ 64 │  ← logo 64×64              │
│        │ ×64│                            │
│        └────┘                            │
│                                          │
│    Title (header, textPrimary)           │  ← center-aligned
│    Subtitle (infoBig, textSecondary)     │
│    Caption (info, textSecondary)         │
│                                          │
│    [Badge]  💰 $1.25M                    │  ← row of badges and key metrics
│                                          │
└──────────────────────────────────────────┘
```

---

## Adaptation для iPhone size classes

В MVP — только iPhone portrait. Не оптимизируем под iPad/landscape отдельно. Контент должен корректно растягиваться через `frame(maxWidth: .infinity)`, но без специальной адаптации.

iPad — Phase 4+: sidebar layout (NavigationSplitView).

---

## Dark mode

**Только dark.** Light theme не поддерживаем — в `GameSearchApp.swift` стоит `.preferredColorScheme(.dark)`.

Все цвета в `Assets.xcassets` могут иметь Any/Dark вариант, но используется только Dark.

---

## Animation library (общие константы)

Не вводим отдельный enum AnimationTokens, но используем consistent значения:

| Use | Animation |
|---|---|
| Стандартный transition | `.easeOut(duration: 0.2)` |
| Spring для tabs / sheets | `.spring(duration: 0.3)` |
| LIVE pulse | `.easeInOut(duration: 1.5).repeatForever(autoreverses: true)` |
| Skeleton shimmer | `.linear(duration: 1.2).repeatForever(autoreverses: false)` |
| Press feedback | `.easeOut(duration: 0.1)` |
| Spoiler reveal | `.spring(duration: 0.25)` |

---

_Last updated: 2026-05-25_
