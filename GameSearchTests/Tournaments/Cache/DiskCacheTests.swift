//
//  DiskCacheTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class DiskCacheTests: XCTestCase {

    private var tempDir: URL!
    private var cache: DiskCache!

    override func setUp() async throws {
        try await super.setUp()
        tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DiskCacheTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        cache = DiskCache(directory: tempDir)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDir)
        cache = nil
        tempDir = nil
        try await super.tearDown()
    }

    func test_read_afterWrite_returnsValue() async {
        let value = ["a", "b", "c"]
        await cache.write(value, key: "test:list:1", ttl: 60)

        let result: [String]? = await cache.read([String].self, key: "test:list:1")

        XCTAssertEqual(result, value)
    }

    func test_read_afterTTLExpired_returnsNil() async {
        await cache.write(["x"], key: "exp", ttl: 0.05)

        try? await Task.sleep(nanoseconds: 100_000_000)
        let result: [String]? = await cache.read([String].self, key: "exp")

        XCTAssertNil(result)
    }

    func test_invalidate_byPrefix_removesMatching() async {
        await cache.write(1, key: "tournaments:list:cs2:running", ttl: 60)
        await cache.write(2, key: "tournaments:list:dota2:upcoming", ttl: 60)
        await cache.write(3, key: "matches:list:cs2:past", ttl: 60)

        await cache.invalidate(prefix: "tournaments:")

        let t: Int? = await cache.read(Int.self, key: "tournaments:list:cs2:running")
        let m: Int? = await cache.read(Int.self, key: "matches:list:cs2:past")
        XCTAssertNil(t)
        XCTAssertEqual(m, 3)
    }

    func test_invalidateAll_clearsEverything() async {
        await cache.write(1, key: "a", ttl: 60)
        await cache.write(2, key: "b", ttl: 60)

        await cache.invalidateAll()

        let a: Int? = await cache.read(Int.self, key: "a")
        XCTAssertNil(a)
    }

    func test_roundTrip_domainObject() async {
        let tournament = Tournament.fixture()

        await cache.write(tournament, key: "t:detail:1", ttl: 60)

        let restored: Tournament? = await cache.read(Tournament.self, key: "t:detail:1")
        XCTAssertEqual(restored?.id, tournament.id)
        XCTAssertEqual(restored?.slug, tournament.slug)
    }
}
