# 06 — Data Models

Полный набор Swift-моделей для модуля. Domain-модели **отдельно** от DTO PandaScore.

Все модели:
- `struct` (value-types).
- `Identifiable` если имеют `id`.
- `Hashable` для использования в `ForEach` и `NavigationStack`.
- `Sendable` где возможно (Swift 6 готовность).
- Без `@objc`, без NS-классов.

---

## Type aliases

Чтобы не путать ID разных сущностей и иметь type-safety:

```swift
typealias TournamentId = Int
typealias MatchId = Int
typealias TeamId = Int
typealias PlayerId = Int
typealias LeagueId = Int
typealias SerieId = Int
typealias GameId = Int
```

В Phase 2 можно превратить в opaque-types (`struct TournamentId(value: Int)`) если станет нужно.

---

## Enums

```swift
enum Game: String, Hashable, Sendable, CaseIterable {
    case cs2
    case dota2

    var displayName: String {
        switch self {
        case .cs2: "CS2"
        case .dota2: "Dota 2"
        }
    }

    var pandaScorePrefix: String {
        switch self {
        case .cs2: "csgo"
        case .dota2: "dota2"
        }
    }

    var accentColor: Color {
        switch self {
        case .cs2: EAColor.csColor
        case .dota2: EAColor.dotaColor
        }
    }

    var iconName: String {  // имя ассета в Assets.xcassets
        switch self {
        case .cs2: "cs"        // переиспользуем существующий cs.imageset
        case .dota2: "dota2"   // переиспользуем существующий dota2.imageset
        }
    }
}

enum Tier: String, Hashable, Sendable {
    case s, a, b, c, d

    var displayName: String {
        rawValue.uppercased()
    }

    var color: Color {
        switch self {
        case .s: EAColor.purpleAccent
        case .a: EAColor.info2
        case .b, .c, .d: EAColor.textSecondary
        }
    }
}

enum TournamentSegment: Hashable, Sendable, CaseIterable {
    case running
    case upcoming
    case past

    var pandaScorePath: String {
        switch self {
        case .running: "running"
        case .upcoming: "upcoming"
        case .past: "past"
        }
    }
}

enum MatchStatus: String, Hashable, Sendable {
    case notStarted = "not_started"
    case running
    case finished
    case canceled
    case postponed

    var isLive: Bool { self == .running }
    var isOver: Bool { self == .finished || self == .canceled }
}

enum MatchType: String, Hashable, Sendable {
    case bestOf = "best_of"
    case allGamesPlayed = "all_games_played"
    case ftw = "ftw"
    case singleGame = "single_game"
}

enum StreamPlatform: Hashable, Sendable {
    case twitch(channel: String)
    case youtube(videoId: String?)
    case other(url: URL)
}

enum WinnerType: String, Hashable, Sendable {
    case team = "Team"
    case player = "Player"
}
```

---

## Tournament

```swift
struct Tournament: Identifiable, Hashable, Sendable {
    let id: TournamentId
    let slug: String
    let name: String              // "Group Stage" / "Playoffs"
    let tier: Tier?
    let game: Game
    let league: League
    let serie: Serie
    let beginAt: Date?
    let endAt: Date?
    let prizepool: Prizepool?     // см. ниже
    let country: String?          // ISO 3166-1 alpha-2 ("DK", "RU")
    let region: String?           // "EUROPE", "ASIA"
    let liveSupported: Bool
    let modifiedAt: Date?

    // Опциональные доп. данные (заполнены только в details-fetch)
    let matches: [Match]?
    let participants: [TournamentParticipant]?

    var displayTitle: String {
        // "PGL — Major Copenhagen 2026 · Group Stage"
        "\(league.name) — \(serie.name) · \(name)"
    }

    /// Заголовок для списков: содержательное имя серии, fallback на
    /// "<League> <year>" если у серии пустое `name` (бывает у "годовых"
    /// серий вроде CS Asia Championships, где serie.full_name == "2026").
    var displayListTitle: String { ... }

    var isLive: Bool {
        guard let begin = beginAt, let end = endAt else { return false }
        let now = Date()
        return begin <= now && now <= end
    }
}

struct Prizepool: Hashable, Sendable {
    let amount: Decimal
    let currency: String          // "United States Dollar" / "USD"

    var formatted: String {
        // "$1 250 000" или "1.25M USD"
        // см. PrizepoolFormatter
    }
}
```

### TournamentSeriesGroup (клиентский агрегат)

PandaScore отдаёт каждую стадию серии как отдельный `Tournament` (например, серия «CS Asia Championships 2026» = `Group A` + `Group B` + `Playoffs` — три объекта). При этом `prizepool` обычно есть только у Playoffs. Чтобы в списке не было дубликатов и пропусков по призовому, в Phase 1.A на клиенте делается группировка по `serie.id`:

```swift
struct TournamentSeriesGroup: Identifiable, Hashable, Sendable {
    var id: SerieId { serie.id }
    let serie: Serie
    let league: League
    let game: Game
    let stages: [Tournament]               // отсортированы по begin_at, tie-break по name/id

    var beginAt: Date? { stages.compactMap(\.beginAt).min() }
    var endAt:   Date? { stages.compactMap(\.endAt).max() }
    var prizepool: Prizepool? { stages.compactMap(\.prizepool).first }
    var tier: Tier? { ...  /* минимальный rank среди стадий */ }
    var isLive: Bool { stages.contains(where: \.isLive) }
    var representativeStage: Tournament { /* live > последняя по begin_at > первая */ }
    var stageNamesJoined: String { stages.map(\.name).joined(separator: " · ") }
    var displayTitle: String { representativeStage.displayListTitle }

    static func makeGroups(from tournaments: [Tournament]) -> [TournamentSeriesGroup]
}
```

Используется внутри `TournamentsListViewModel`: `state.loaded(groups: [TournamentSeriesGroup])`. Карточка списка (`TournamentCard`) принимает группу, а не одиночный турнир. Навигация выполняется на `representativeStage.slug`.

В Phase 1.B (детали) можно либо открывать конкретную стадию (как сейчас), либо подгружать все стадии серии для отображения tab «Матчи» по группам.

---

## Match

```swift
struct Match: Identifiable, Hashable, Sendable {
    let id: MatchId
    let name: String              // "FaZe vs NaVi"
    let status: MatchStatus
    let matchType: MatchType
    let numberOfGames: Int        // 3 для BO3, 5 для BO5
    let scheduledAt: Date?
    let beginAt: Date?
    let endAt: Date?
    let draw: Bool
    let forfeit: Bool
    let tournamentId: TournamentId
    let leagueId: LeagueId
    let game: Game
    let opponents: [Opponent]     // 2 элемента почти всегда
    let results: [MatchResult]    // score по командам
    let games: [Game.PlayedGame]  // картины-карты для CS2 / игры для Dota
    let streams: [Stream]
    let winnerId: TeamId?

    var isLive: Bool { status == .running }
    var isOver: Bool { status.isOver }
    var winner: Team? {
        guard let wid = winnerId else { return nil }
        return opponents.first { $0.team.id == wid }?.team
    }
}

struct Opponent: Hashable, Sendable {
    let team: Team
}

struct MatchResult: Hashable, Sendable {
    let teamId: TeamId
    let score: Int
}

extension Match {
    struct PlayedGame: Identifiable, Hashable, Sendable {
        let id: Int
        let position: Int          // 1, 2, 3...
        let status: MatchStatus    // finished / running / not_started
        let mapName: String?       // "Mirage" / "Inferno" — для CS2; nil для Dota
        let winner: TeamId?
        let beginAt: Date?
        let endAt: Date?
        let length: TimeInterval?  // длительность в секундах
        let videoUrl: URL?
    }
}
```

---

## Stream

```swift
struct Stream: Hashable, Sendable, Identifiable {
    let id: String                // computed from raw_url
    let language: String          // "ru", "en"
    let rawUrl: URL
    let embedUrl: URL?
    let main: Bool
    let official: Bool
    let platform: StreamPlatform

    var displayLanguage: String {
        // "🇷🇺 Русский" / "🇬🇧 English"
    }
}
```

---

## Team

```swift
struct Team: Identifiable, Hashable, Sendable {
    let id: TeamId
    let name: String
    let slug: String
    let acronym: String?          // "FAZE"
    let location: String?         // "EU", "RU"
    let imageUrl: URL?
    let currentGame: Game?
    let players: [Player]?        // заполнено только при detail-fetch
    let modifiedAt: Date?
}
```

---

## Player

```swift
struct Player: Identifiable, Hashable, Sendable {
    let id: PlayerId
    let nickname: String          // "karrigan"
    let firstName: String?
    let lastName: String?
    let nationality: String?      // ISO alpha-2
    let age: Int?
    let birthday: Date?
    let role: String?             // "Coach" / "AWPer" / "Captain"
    let active: Bool
    let imageUrl: URL?
    let currentTeam: Team?
    let currentGame: Game?

    var displayFullName: String? {
        switch (firstName, lastName) {
        case (let f?, let l?): "\(f) \(l)"
        case (let f?, nil): f
        case (nil, let l?): l
        default: nil
        }
    }
}
```

---

## League & Serie

```swift
struct League: Identifiable, Hashable, Sendable {
    let id: LeagueId
    let name: String              // "PGL"
    let slug: String
    let imageUrl: URL?
}

struct Serie: Identifiable, Hashable, Sendable {
    let id: SerieId
    let name: String              // "Major Copenhagen 2026"
    let fullName: String?         // "Major Copenhagen 2026 March"
    let year: Int?
    let season: String?
}
```

---

## Tournament Participant

```swift
struct TournamentParticipant: Hashable, Sendable, Identifiable {
    var id: TeamId { team.id }
    let team: Team
    let players: [Player]
}
```

---

## Standings & Brackets

```swift
struct Standing: Identifiable, Hashable, Sendable {
    var id: TeamId { team.id }
    let team: Team
    let rank: Int
    let wins: Int
    let losses: Int
    let ties: Int?
    let points: Int?
}

struct Bracket: Hashable, Sendable {
    let rounds: [BracketRound]
}

struct BracketRound: Hashable, Sendable {
    let name: String              // "Quarterfinals", "Semifinals", "Grand Final"
    let matches: [Match]
}
```

---

## Favorites (Phase 1)

```swift
struct Favorite: Hashable, Sendable, Codable {
    enum Kind: String, Codable, Hashable, Sendable {
        case team
        case tournament
        case player
    }

    let kind: Kind
    let entityId: Int
    let displayName: String       // снапшот, чтобы не fetch'ить детали для списка
    let imageUrl: URL?
    let game: Game?
    let addedAt: Date
}
```

---

## DTO (PandaScore) — отдельные типы

DTO живут в `Services/Tournaments/Models/DTO/` и **не утекают наружу**. Они декодируются из JSON один в один с ответом API.

Пример:

```swift
struct PandaScoreTournamentDTO: Decodable {
    let id: Int
    let slug: String
    let name: String
    let tier: String?
    let begin_at: String?         // ISO-8601 string, парсим в Date в Mapper
    let end_at: String?
    let prizepool: String?
    let country: String?
    let region: String?
    let live_supported: Bool?
    let modified_at: String?
    let league: PandaScoreLeagueDTO?
    let serie: PandaScoreSerieDTO?
    let videogame: PandaScoreVideogameDTO?
    let matches: [PandaScoreMatchDTO]?
    let expected_roster: [PandaScoreRosterDTO]?
}
```

Mapper:

```swift
enum TournamentMapper {
    static func map(_ dto: PandaScoreTournamentDTO) -> Tournament? {
        guard let league = dto.league.flatMap(LeagueMapper.map),
              let serie = dto.serie.flatMap(SerieMapper.map),
              let game = dto.videogame.flatMap(GameMapper.map)
        else {
            return nil
        }

        return Tournament(
            id: dto.id,
            slug: dto.slug,
            name: dto.name,
            tier: dto.tier.flatMap(Tier.init(rawValue:)),
            game: game,
            league: league,
            serie: serie,
            beginAt: dto.begin_at.flatMap(ISO8601DateFormatter.shared.date(from:)),
            // ...
        )
    }
}
```

---

## Persistence модели (для Firestore — Phase 1+)

Когда добавляем избранное в Firestore, нужны Codable-формы:

```swift
extension Favorite: Codable {
    // уже Codable, но в Firestore-документе храним в плоской структуре:
    // users/{anon_uid}/favorites/{kind}_{id}
}
```

Firestore коллекции (план):

```
favorites/{user_uid}/items/{favorite_id}
└─ kind, entityId, displayName, imageUrl, game, addedAt

push_subscriptions/{user_uid}
└─ fcmToken, favorites: [{kind, entityId}], quietHours: {...}

tournaments_cache/{tournament_id}      ← L3 cache (Phase 1+)
└─ payload, fetchedAt
```

---

## Конвенции для моделей

1. **Никаких `var`** в моделях — только `let`. Изменения через `with`-методы:
   ```swift
   extension Tournament {
       func with(matches: [Match]) -> Tournament {
           Tournament(/* все поля */, matches: matches, /* ... */)
       }
   }
   ```
2. **Опциональные поля помечены `?`** — никаких `String` для поля, которое API может прислать `null`.
3. **Никаких `Bool` с двойным отрицанием** — `isHidden` плохо, `isVisible` хорошо.
4. **Даты — `Date`**, парсим в маппере. Не таскать `String`.
5. **URL — `URL`**, не `String`. Если приходит невалидный — Mapper возвращает `nil` для всей модели.
6. **Цвета и шрифты НЕ хранятся в моделях** — это computed-helpers через extensions для UI.

---

_Last updated: 2026-05-25_
