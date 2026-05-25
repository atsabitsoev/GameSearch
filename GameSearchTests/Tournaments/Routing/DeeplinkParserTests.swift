//
//  DeeplinkParserTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class DeeplinkParserTests: XCTestCase {

    func test_parse_articleSlug_returnsArticles() {
        let url = URL(string: "gamesearch://news/some-article")!
        XCTAssertEqual(Deeplink(from: url), .articles(slug: "some-article"))
    }

    func test_parse_newsTabOnly_returnsArticlesNil() {
        let url = URL(string: "gamesearch://news")!
        XCTAssertEqual(Deeplink(from: url), .articles(slug: nil))
    }

    func test_parse_tournamentsTabWithGame_returnsTabWithGame() {
        let url = URL(string: "gamesearch://tournaments/cs2")!
        XCTAssertEqual(Deeplink(from: url), .tournamentsTab(game: .cs2))
    }

    func test_parse_tournamentsTabWithoutGame_returnsTabWithoutGame() {
        let url = URL(string: "gamesearch://tournaments")!
        XCTAssertEqual(Deeplink(from: url), .tournamentsTab(game: nil))
    }

    func test_parse_tournamentDetails_returnsTournamentSlug() {
        let url = URL(string: "gamesearch://tournament/csgo-pgl-major-copenhagen-2026")!
        XCTAssertEqual(
            Deeplink(from: url),
            .tournamentDetails(idOrSlug: "csgo-pgl-major-copenhagen-2026")
        )
    }

    func test_parse_matchDetails_parsesIntegerId() {
        let url = URL(string: "gamesearch://match/1071234")!
        XCTAssertEqual(Deeplink(from: url), .matchDetails(id: 1_071_234))
    }

    func test_parse_matchDetails_withNonInteger_returnsNil() {
        let url = URL(string: "gamesearch://match/abc")!
        XCTAssertNil(Deeplink(from: url))
    }

    func test_parse_unknownPath_returnsNil() {
        let url = URL(string: "gamesearch://unknown/path")!
        XCTAssertNil(Deeplink(from: url))
    }

    func test_parse_emptyUrl_returnsNil() {
        let url = URL(string: "gamesearch://")!
        XCTAssertNil(Deeplink(from: url))
    }
}
