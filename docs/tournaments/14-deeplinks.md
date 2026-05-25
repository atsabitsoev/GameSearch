# 14 — Deeplinks

URL-схемы для модуля «Турниры» — для использования из push-уведомлений, share-кнопок, внешних ссылок.

В проекте используется кастомная URL scheme **`gamesearch://`** + парсер в `Router/Deeplink.swift`. Расширяем под турниры.

---

## URL Schemes

### Custom URL scheme — основной канал

| URL | Действие |
|---|---|
| `gamesearch://tournaments` | Открыть таб «Турниры» |
| `gamesearch://tournaments/cs2` | Открыть таб + CS2 + сегмент «Сейчас» |
| `gamesearch://tournaments/dota2` | Открыть таб + Dota 2 + сегмент «Сейчас» |
| `gamesearch://tournament/<id_or_slug>` | Открыть детали турнира |
| `gamesearch://match/<id>` | Открыть детали матча |
| `gamesearch://team/<id>` | Открыть профиль команды (Phase 2) |
| `gamesearch://player/<id>` | Открыть профиль игрока (Phase 2) |
| `gamesearch://favorites` | Открыть таб + сегмент «Мои» (Phase 1) |

### Universal Links (Phase 2+)

Когда понадобится открывать ссылки из веба или социальных сетей — поднимаем universal links:

| URL | Действие |
|---|---|
| `https://gamesearch.app/tournament/<slug>` | То же, что `gamesearch://tournament/<slug>` |
| `https://gamesearch.app/match/<id>` | То же, что `gamesearch://match/<id>` |

Требует:
- Файл `apple-app-site-association` на домене.
- Entitlement `Associated Domains` в Xcode.
- Домен (пока нет).

В MVP — **только custom URL scheme**.

---

## Поведение при обработке

### Открытие из cold start
```
1. Приложение запускается через UIApplicationDelegate.application(_:open:options:)
   или SwiftUI .onOpenURL(_:)
2. Deeplink парсится → DeeplinkRoute
3. RootView создаёт корневой NavigationStack
4. Router.openDeeplink(route) → push соответствующего экрана
```

### Открытие при работающем приложении
```
1. .onOpenURL(_:) срабатывает
2. Парсится deeplink
3. Если текущий таб — Турниры → push на текущий стек.
   Иначе → переключение на таб Турниры → push в его стек.
```

### Открытие из push-уведомления
```
1. didReceive(_:userInfo:) или UNUserNotificationCenterDelegate
2. В payload push'а ожидаем поле `deeplink: "gamesearch://match/12345"`
3. Парсим как обычный deeplink
4. Открываем
5. Аналитика: push_opened с параметрами
```

---

## Парсер (Deeplink.swift)

Расширить существующий `Deeplink.swift`:

```swift
enum Deeplink: Hashable {
    // Существующие (если есть):
    // case clubs
    // case clubDetails(id: ClubId)

    // Новые:
    case tournamentsTab(game: Game?)
    case tournamentDetails(idOrSlug: String)
    case matchDetails(id: MatchId)
    case teamProfile(id: TeamId)            // Phase 2
    case playerProfile(id: PlayerId)        // Phase 2
    case favorites                          // Phase 1

    static func parse(_ url: URL) -> Deeplink? {
        guard url.scheme == "gamesearch" else { return nil }
        guard let host = url.host else { return nil }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "tournaments":
            if let first = pathComponents.first,
               let game = Game(rawValue: first) {
                return .tournamentsTab(game: game)
            }
            return .tournamentsTab(game: nil)

        case "tournament":
            guard let idOrSlug = pathComponents.first else { return nil }
            return .tournamentDetails(idOrSlug: idOrSlug)

        case "match":
            guard let idStr = pathComponents.first,
                  let id = Int(idStr) else { return nil }
            return .matchDetails(id: id)

        case "team":
            guard let idStr = pathComponents.first,
                  let id = Int(idStr) else { return nil }
            return .teamProfile(id: id)

        case "player":
            guard let idStr = pathComponents.first,
                  let id = Int(idStr) else { return nil }
            return .playerProfile(id: id)

        case "favorites":
            return .favorites

        default:
            return nil
        }
    }
}
```

---

## Генерация ссылок (для Share)

```swift
extension Deeplink {
    var url: URL {
        switch self {
        case .tournamentsTab(let game):
            if let game = game {
                return URL(string: "gamesearch://tournaments/\(game.rawValue)")!
            }
            return URL(string: "gamesearch://tournaments")!

        case .tournamentDetails(let idOrSlug):
            return URL(string: "gamesearch://tournament/\(idOrSlug)")!

        case .matchDetails(let id):
            return URL(string: "gamesearch://match/\(id)")!

        case .teamProfile(let id):
            return URL(string: "gamesearch://team/\(id)")!

        case .playerProfile(let id):
            return URL(string: "gamesearch://player/\(id)")!

        case .favorites:
            return URL(string: "gamesearch://favorites")!
        }
    }
}
```

Использование в `ShareLink`:

```swift
ShareLink(
    item: Deeplink.tournamentDetails(idOrSlug: tournament.slug).url,
    subject: Text(tournament.displayTitle),
    message: Text("Посмотри турнир: \(tournament.displayTitle)")
)
```

---

## Router в роли диспетчера

`TournamentsRouter` обрабатывает deeplinks внутри своего таба:

```swift
@MainActor
final class TournamentsRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedGame: Game = .cs2
    @Published var selectedSegment: TournamentSegment = .running

    func push(_ route: TournamentsRoute) {
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func handleDeeplink(_ deeplink: Deeplink) {
        switch deeplink {
        case .tournamentsTab(let game):
            popToRoot()
            if let game { selectedGame = game }
        case .tournamentDetails(let idOrSlug):
            popToRoot()
            // нужен async fetch для получения id из slug, или принять оба
            path.append(TournamentsRoute.tournamentDetailsByIdOrSlug(idOrSlug))
        case .matchDetails(let id):
            popToRoot()
            path.append(TournamentsRoute.matchDetails(id))
        case .teamProfile(let id):
            popToRoot()
            path.append(TournamentsRoute.teamProfile(id))
        case .playerProfile(let id):
            popToRoot()
            path.append(TournamentsRoute.playerProfile(id))
        case .favorites:
            popToRoot()
            selectedSegment = /* .favorites */
        }
    }
}
```

---

## Регистрация URL scheme в Info.plist

Если ещё не сделано — добавить в `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.bitsoev.gamesearchea</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>gamesearch</string>
        </array>
    </dict>
</array>
```

Проверка: в Safari ввести `gamesearch://tournaments` — должно открыть приложение.

---

## Тестирование

### Симулятор
```bash
xcrun simctl openurl booted "gamesearch://tournament/csgo-pgl-major-copenhagen-2026"
xcrun simctl openurl booted "gamesearch://match/1071234"
```

### Реальное устройство
1. Установить приложение.
2. Открыть Notes / Safari.
3. Ввести `gamesearch://match/1071234`.
4. Тап → откроет приложение.

### Через push-уведомление (Phase 1)
Push payload должен содержать:
```json
{
  "aps": {
    "alert": {
      "title": "Скоро матч FaZe",
      "body": "Через 15 минут — FaZe vs NaVi"
    },
    "sound": "default"
  },
  "deeplink": "gamesearch://match/1071234",
  "kind": "match_starting"
}
```

В `UNUserNotificationCenterDelegate`:
```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    if let deeplinkStr = response.notification.request.content.userInfo["deeplink"] as? String,
       let url = URL(string: deeplinkStr),
       let deeplink = Deeplink.parse(url) {
        // route to handler
    }
    completionHandler()
}
```

---

## Edge cases

| Случай | Поведение |
|---|---|
| Невалидный URL (`gamesearch://random`) | Открываем приложение на дефолтном табе, никаких alerts |
| Турнир/матч не найден в API (404) | Показываем экран с error state «Турнир не найден» + кнопка «На главную» |
| Slug содержит спецсимволы | URL-encode на стороне генерации; decode при парсинге |
| Deeplink при cold start без интернета | Открываем экран загрузки → если не получилось → error state с retry |
| Push с deeplink, но приложение удалили и поставили заново | iOS обработает как новое уведомление, deeplink сработает корректно |

---

## Аналитика deeplinks

| Event | Когда | Параметры |
|---|---|---|
| `deeplink_opened` | Распарсен и обработан валидный deeplink | `kind: tournament\|match\|team\|player\|tab`, `source: cold_start\|warm_start\|push` |
| `deeplink_invalid` | URL не распарсился | `url: <sanitized>` (без id, только path pattern) |

---

_Last updated: 2026-05-25_
