//
//  Deeplink.swift
//  GameSearch
//
//  Created by Ацамаз on 27.12.2025.
//

import Foundation

enum Deeplink {
    case articles(slug: String?)

    init?(from url: URL) {
        let components = url.pathComponents
        guard components.count > 1 else { return nil }
        if components[1] == "news" {
            if components.count > 2 {
                let articleSlug = components[2]
                self = .articles(slug: articleSlug)
            } else {
                self = .articles(slug: nil)
            }
        } else {
            return nil
        }
    }
}
