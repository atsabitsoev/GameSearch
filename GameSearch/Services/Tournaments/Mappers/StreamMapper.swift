//
//  StreamMapper.swift
//  GameSearch
//

import Foundation

enum StreamMapper {

    static func map(_ dto: PandaScoreStreamDTO?) -> Stream? {
        guard
            let dto,
            let rawUrlString = dto.rawUrl,
            let rawUrl = URL(string: rawUrlString)
        else { return nil }
        let platform = detectPlatform(rawUrl: rawUrl)
        return Stream(
            id: rawUrl.absoluteString,
            language: dto.language ?? "",
            rawUrl: rawUrl,
            embedUrl: dto.embedUrl.flatMap(URL.init(string:)),
            main: dto.main ?? false,
            official: dto.official ?? false,
            platform: platform
        )
    }

    static func mapAll(_ dtos: [PandaScoreStreamDTO]?) -> [Stream] {
        (dtos ?? []).compactMap(map)
    }

    static func detectPlatform(rawUrl: URL) -> StreamPlatform {
        let host = rawUrl.host?.lowercased() ?? ""
        if host.contains("twitch.tv") {
            let channel = extractTwitchChannel(from: rawUrl)
            return .twitch(channel: channel)
        }
        if host.contains("youtube.com") || host.contains("youtu.be") {
            let videoId = extractYouTubeVideoId(from: rawUrl)
            return .youtube(videoId: videoId)
        }
        return .other(url: rawUrl)
    }

    static func extractTwitchChannel(from url: URL) -> String {
        let pathComponents = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
        return pathComponents.first ?? ""
    }

    static func extractYouTubeVideoId(from url: URL) -> String? {
        if url.host?.lowercased().contains("youtu.be") == true {
            let path = url.path.replacingOccurrences(of: "/", with: "")
            return path.isEmpty ? nil : path
        }
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let videoId = components.queryItems?.first(where: { $0.name == "v" })?.value {
            return videoId
        }
        return nil
    }
}
