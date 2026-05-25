//
//  StreamRow.swift
//  GameSearch
//
//  Single stream row inside `MatchStreamsList`. Tap-handling logic
//  lives in `StreamOpener` (below) — attempts to deeplink into the
//  native app (Twitch / YouTube), falls back to opening the original
//  URL in Safari. Failure to open routes through `onOpenFailed` so the
//  VM can report analytics and the view can surface a toast.
//

import SwiftUI
import UIKit

struct StreamRow: View {
    let stream: Stream
    let onTap: () -> Void
    let onOpenFailed: (TournamentsAnalyticsEvent.StreamOpenFailReason) -> Void

    var body: some View {
        Button {
            handleTap()
        } label: {
            HStack(spacing: 12) {
                languageBlock
                VStack(alignment: .leading, spacing: 4) {
                    Text(channelLabel)
                        .font(EAFont.smallTitle)
                        .foregroundStyle(EAColor.textPrimary)
                        .lineLimit(1)
                    badgeRow
                }
                Spacer(minLength: 8)
                openCTA
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(EAColor.secondaryBackground)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(accessibilityLabel))
    }
}

// MARK: - Subviews

private extension StreamRow {

    var languageBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let flag = StreamRow.languageFlag(for: stream.language) {
                Text(flag).font(EAFont.infoBig)
            }
            Text(StreamRow.languageDisplayName(for: stream.language))
                .font(EAFont.description)
                .foregroundStyle(EAColor.textSecondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    var channelLabel: String {
        switch stream.platform {
        case .twitch(let channel) where !channel.isEmpty:
            return channel
        case .twitch:
            return TournamentsStrings.streamPlatformTwitch
        case .youtube:
            return TournamentsStrings.streamPlatformYouTube
        case .other(let url):
            return url.host?.replacingOccurrences(of: "www.", with: "") ?? TournamentsStrings.streamPlatformOther
        }
    }

    @ViewBuilder
    var badgeRow: some View {
        let badges = activeBadges
        if !badges.isEmpty {
            HStack(spacing: 6) {
                ForEach(badges, id: \.self) { text in
                    badge(text: text)
                }
            }
        } else {
            EmptyView()
        }
    }

    var activeBadges: [String] {
        var badges: [String] = []
        if stream.main { badges.append(TournamentsStrings.streamMainBadge) }
        if stream.official { badges.append(TournamentsStrings.streamOfficialBadge) }
        return badges
    }

    func badge(text: String) -> some View {
        Text(text)
            .font(EAFont.infoSmall)
            .foregroundStyle(EAColor.textSecondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(EAColor.textSecondary.opacity(0.45), lineWidth: 1)
            )
    }

    var openCTA: some View {
        HStack(spacing: 4) {
            Text(ctaText)
                .font(EAFont.infoBold)
                .foregroundStyle(EAColor.textPrimary)
            Image(systemName: "arrow.up.right.square")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(EAColor.textSecondary)
        }
    }

    var ctaText: String {
        switch stream.platform {
        case .twitch: return TournamentsStrings.streamPlatformTwitch
        case .youtube: return TournamentsStrings.streamPlatformYouTube
        case .other: return TournamentsStrings.streamOpenGeneric
        }
    }

    var accessibilityLabel: String {
        let lang = StreamRow.languageDisplayName(for: stream.language)
        return "\(channelLabel), \(lang). \(ctaText)"
    }
}

// MARK: - Open handler

private extension StreamRow {
    func handleTap() {
        onTap()
        StreamOpener.open(stream) { reason in
            onOpenFailed(reason)
        }
    }
}

// MARK: - Static helpers (language)

extension StreamRow {

    /// Maps PandaScore-style language codes to a flag emoji. PandaScore
    /// uses ISO 639-1 with occasional locale tags ("en", "ru", "pt-br").
    static func languageFlag(for code: String) -> String? {
        let normalised = code.lowercased()
        let country: String?
        switch normalised {
        case "en": country = "GB"
        case "ru": country = "RU"
        case "uk", "ukr": country = "UA"
        case "es": country = "ES"
        case "pt", "pt-br", "br": country = "BR"
        case "de": country = "DE"
        case "fr": country = "FR"
        case "it": country = "IT"
        case "pl": country = "PL"
        case "zh", "zh-cn": country = "CN"
        case "ja": country = "JP"
        case "ko": country = "KR"
        case "tr": country = "TR"
        case "ar": country = "SA"
        default:
            // Try splitting "xx-YY" and using the country tag.
            if let suffix = normalised.split(separator: "-").dropFirst().first {
                country = String(suffix).uppercased()
            } else {
                country = nil
            }
        }
        return CountryFlag.emoji(from: country)
    }

    static func languageDisplayName(for code: String) -> String {
        let normalised = code.lowercased()
        switch normalised {
        case "ru": return "Русский"
        case "en": return "English"
        case "uk", "ukr": return "Українська"
        case "es": return "Español"
        case "pt", "pt-br", "br": return "Português"
        case "de": return "Deutsch"
        case "fr": return "Français"
        case "it": return "Italiano"
        case "pl": return "Polski"
        case "zh", "zh-cn": return "中文"
        case "ja": return "日本語"
        case "ko": return "한국어"
        case "tr": return "Türkçe"
        case "ar": return "العربية"
        case "":
            return TournamentsStrings.unknownLanguage
        default:
            return code.uppercased()
        }
    }
}

// MARK: - Stream Opener

/// Tries native deeplinks first, then falls back to the raw URL in
/// Safari. `onFailure` is called only when **both** attempts fail
/// (deeplink unsupported AND the raw URL also won't open). The
/// `app_not_installed` reason is used when we attempted a native
/// deeplink and it failed but raw URL did succeed (caller can still
/// log that the deeplink path failed) — but for the toast we only
/// invoke `onFailure` for hard failures.
enum StreamOpener {

    @MainActor
    static func open(_ stream: Stream, onFailure: @escaping (TournamentsAnalyticsEvent.StreamOpenFailReason) -> Void) {
        // 1) Try platform-specific deeplink.
        if let deeplink = deeplink(for: stream.platform) {
            UIApplication.shared.open(deeplink, options: [:]) { success in
                if success { return }
                // 2) Native app missing → fallback to raw URL.
                openRaw(stream.rawUrl) { rawOK in
                    if !rawOK {
                        onFailure(.appNotInstalled)
                    }
                }
            }
            return
        }
        // No deeplink available — open raw URL directly.
        openRaw(stream.rawUrl) { ok in
            if !ok { onFailure(.invalidUrl) }
        }
    }

    @MainActor
    private static func openRaw(_ url: URL, completion: @escaping (Bool) -> Void) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }

    static func deeplink(for platform: StreamPlatform) -> URL? {
        switch platform {
        case .twitch(let channel) where !channel.isEmpty:
            return URL(string: "twitch://stream/\(channel)")
        case .twitch:
            return nil
        case .youtube(let videoId):
            if let id = videoId, !id.isEmpty {
                return URL(string: "youtube://watch?v=\(id)")
            }
            return nil
        case .other:
            return nil
        }
    }
}

// MARK: - Preview

#Preview {
    let twitch = Stream(
        id: "1",
        language: "ru",
        rawUrl: URL(string: "https://www.twitch.tv/maincast")!,
        embedUrl: nil, main: true, official: false,
        platform: .twitch(channel: "maincast")
    )
    let youtube = Stream(
        id: "2",
        language: "en",
        rawUrl: URL(string: "https://www.youtube.com/watch?v=abc123")!,
        embedUrl: nil, main: false, official: true,
        platform: .youtube(videoId: "abc123")
    )
    let other = Stream(
        id: "3",
        language: "pt-br",
        rawUrl: URL(string: "https://example.com/live")!,
        embedUrl: nil, main: false, official: false,
        platform: .other(url: URL(string: "https://example.com/live")!)
    )
    return ScrollView {
        VStack(spacing: 12) {
            StreamRow(stream: twitch, onTap: {}, onOpenFailed: { _ in })
            StreamRow(stream: youtube, onTap: {}, onOpenFailed: { _ in })
            StreamRow(stream: other, onTap: {}, onOpenFailed: { _ in })
        }
        .padding()
    }
    .background(EAColor.background)
    .preferredColorScheme(.dark)
}
