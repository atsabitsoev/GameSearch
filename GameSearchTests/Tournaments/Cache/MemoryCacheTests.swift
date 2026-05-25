//
//  MemoryCacheTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class MemoryCacheTests: XCTestCase {

    func test_read_afterWrite_returnsValue() async {
        let cache = MemoryCache()
        let value = ["a", "b"]

        await cache.write(value, key: "test", ttl: 60)

        let result: [String]? = await cache.read([String].self, key: "test")
        XCTAssertEqual(result, value)
    }

    func test_read_afterTTLExpired_returnsNil() async {
        let cache = MemoryCache()
        await cache.write(["a"], key: "test", ttl: 0.05)

        try? await Task.sleep(nanoseconds: 100_000_000)
        let result: [String]? = await cache.read([String].self, key: "test")

        XCTAssertNil(result)
    }

    func test_read_typeMismatch_returnsNil() async {
        let cache = MemoryCache()
        await cache.write(["a"], key: "test", ttl: 60)

        let result: Int? = await cache.read(Int.self, key: "test")

        XCTAssertNil(result)
    }

    func test_invalidate_byPrefix_removesMatching() async {
        let cache = MemoryCache()
        await cache.write(1, key: "tournaments:list:cs2:running", ttl: 60)
        await cache.write(2, key: "tournaments:list:dota2:upcoming", ttl: 60)
        await cache.write(3, key: "matches:list:cs2:past", ttl: 60)

        await cache.invalidate(prefix: "tournaments:")

        let tournamentValue: Int? = await cache.read(Int.self, key: "tournaments:list:cs2:running")
        let matchesValue: Int? = await cache.read(Int.self, key: "matches:list:cs2:past")
        XCTAssertNil(tournamentValue)
        XCTAssertEqual(matchesValue, 3)
    }

    func test_invalidateAll_clearsEverything() async {
        let cache = MemoryCache()
        await cache.write(1, key: "a", ttl: 60)
        await cache.write(2, key: "b", ttl: 60)

        await cache.invalidateAll()

        let a: Int? = await cache.read(Int.self, key: "a")
        let b: Int? = await cache.read(Int.self, key: "b")
        XCTAssertNil(a)
        XCTAssertNil(b)
    }
}
