# ADR-003 — Streams as Deeplink, Not Embedded Player

- **Status**: Accepted
- **Date**: 2026-05-25
- **Owner**: iOS team

## Context

Один из основных user flows в киберспорт-приложении — переход к просмотру стрима матча. PandaScore возвращает в `match.streams_list` список доступных стримов с URLs (преимущественно Twitch и YouTube).

Есть две принципиально разных реализации:
- **Embedded player** внутри приложения — `WKWebView` с Twitch/YouTube embed URL.
- **Deeplink** в нативное приложение (Twitch.app / YouTube.app), fallback в Safari.

Конкуренты делают по-разному:
- **HLTV**, **Liquipedia**, **Escores**: deeplink в нативное приложение.
- **Spectra**: embedded player через WebView.

## Decision

Используем **deeplink** в нативное приложение со списком стримов, fallback в Safari.

Конкретно:
- Парсим `stream.raw_url` для определения платформы.
- Twitch: `twitch://stream/<channel>` (Twitch URL scheme). Fallback: открываем `https://www.twitch.tv/<channel>` через `UIApplication.shared.open()`.
- YouTube: `youtube://www.youtube.com/watch?v=<video_id>`. Fallback: `https://...`.
- Прочие: открываем raw_url через `UIApplication.shared.open()` (Safari или ассоциированное приложение).

Embedded player **НЕ делаем** ни в одной из фаз.

## Alternatives Considered

### А. Embedded WKWebView с Twitch Embed
- **Плюсы**:
  - Пользователь не покидает приложение — теоретически лучше retention.
  - Можно показывать матч-данные параллельно со стримом.
- **Минусы**:
  - Twitch Embed требует `parent=<domain>` параметр и постоянно меняет правила. Регулярные ломки.
  - Quality плеера ниже нативного Twitch (нет picture-in-picture, нет background audio, нет AirPlay).
  - YouTube Embed требует API ключа и квоты.
  - Поддержка плеера = постоянный сервисный долг (релизы Twitch SDK раз в 1-2 месяца).
  - Spectra (единственный конкурент с embedded) — это видно по отзывам пользователей: «плеер часто не грузится».
  - Размер бинарника + memory consumption.
  - Юридические нюансы (нужно соблюдать ToS Twitch для embed).
- **Вердикт**: не оправдано по соотношению effort/value.

### Б. Smart deeplink с in-app browser fallback (SFSafariViewController)
- **Плюсы**: некоторое ощущение «внутри приложения».
- **Минусы**:
  - SFSafariViewController не воспроизводит видео в нормальном качестве по сравнению с native Twitch.app.
  - Авторизация в Twitch не сохраняется (приватная сессия по умолчанию).
  - Subscriber-only стримы недоступны без логина.
- **Вердикт**: вариант с `UIApplication.shared.open()` лучше — открывает Twitch.app если установлен, и только тогда Safari (полноценный).

### В. Native YouTube/Twitch SDK
- **Плюсы**: глубокая интеграция, контроль.
- **Минусы**:
  - YouTube iOS SDK устарел, deprecated.
  - Twitch не предоставляет native SDK для iOS.
  - Только web embeds — см. вариант А.
- **Вердикт**: невозможно технически в полной мере.

## Consequences

### Положительные
- ✅ **Best UX**: пользователь смотрит стрим в полноценном Twitch.app с PiP, AirPlay, авторизацией, чатом.
- ✅ **Нулевая стоимость поддержки**: не зависим от SDK-релизов.
- ✅ **Качество видео**: native клиенты дают лучшее качество.
- ✅ **Быстрее запуск**: фокус на основном продукте.

### Отрицательные
- ❌ Пользователь покидает приложение → потенциально не возвращается → ниже retention в моменте.
- ❌ Если Twitch.app не установлен — открывается Safari, который может предложить установить из App Store.
- ❌ Нет возможности параллельно показывать наши данные.

### Митигации
- При возврате в приложение через iOS gesture — пользователь оказывается там же, где был. NavigationStack сохраняет state.
- Аналитика отслеживает `stream_opened` и `stream_open_failed` — будем знать, насколько часто пользователи доходят до этого шага.
- Если в Phase 5+ появится сильный спрос на embedded player (по фидбеку) — можно сделать опционально через Settings, оставив deeplink как default.

## Implementation Notes

### Определение платформы

```swift
extension Stream {
    var platform: StreamPlatform {
        if rawUrl.host?.contains("twitch.tv") == true,
           let channel = rawUrl.pathComponents.dropFirst().first {
            return .twitch(channel: channel)
        }
        if rawUrl.host?.contains("youtube.com") == true || rawUrl.host?.contains("youtu.be") == true {
            let videoId = extractYouTubeVideoId(from: rawUrl)
            return .youtube(videoId: videoId)
        }
        return .other(url: rawUrl)
    }
}
```

### Открытие

```swift
@MainActor
func openStream(_ stream: Stream) async {
    let nativeUrl: URL?
    let webUrl = stream.rawUrl

    switch stream.platform {
    case .twitch(let channel):
        nativeUrl = URL(string: "twitch://stream/\(channel)")
    case .youtube(let videoId):
        nativeUrl = videoId.flatMap { URL(string: "youtube://www.youtube.com/watch?v=\($0)") }
    case .other:
        nativeUrl = nil
    }

    if let nativeUrl, await UIApplication.shared.canOpenURL(nativeUrl) {
        await UIApplication.shared.open(nativeUrl)
        analytics.report(.streamOpened(platform: stream.platform, language: stream.language, method: "native"))
    } else {
        await UIApplication.shared.open(webUrl)
        analytics.report(.streamOpened(platform: stream.platform, language: stream.language, method: "web"))
    }
}
```

### Info.plist — LSApplicationQueriesSchemes

Чтобы `canOpenURL(twitch://...)` работал на iOS 9+, нужно зарегистрировать схемы:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>twitch</string>
    <string>youtube</string>
</array>
```

## Follow-ups

- Future ADR: если в Phase 5 будет сильный спрос на in-app просмотр — рассмотреть picture-in-picture variant через AVPlayer + парсинг HLS-стрима (юридически серо, не делаем).
- Future ADR: возможно, в Phase 4 добавить пользовательскую предпочтительную платформу для стримов (если есть несколько на одном языке).

---

_Last updated: 2026-05-25_
