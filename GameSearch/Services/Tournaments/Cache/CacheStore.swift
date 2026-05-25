//
//  CacheStore.swift
//  GameSearch
//
//  Two-level cache facade. Services should depend on this, not on
//  MemoryCache / DiskCache directly.
//

import Foundation

protocol CacheStoreProtocol: Sendable {
    func read<T: Codable>(_ type: T.Type, key: String) async -> T?
    func write<T: Codable>(_ value: T, key: String, ttl: TimeInterval) async
    func invalidate(prefix: String) async
    func invalidateAll() async
}

final class CacheStore: CacheStoreProtocol, @unchecked Sendable {

    // MARK: - Layers

    private let memory: MemoryCache
    private let disk: DiskCache?

    // MARK: - Init

    init(memory: MemoryCache = MemoryCache(), disk: DiskCache? = DiskCache()) {
        self.memory = memory
        self.disk = disk
    }

    // MARK: - API

    func read<T: Codable>(_ type: T.Type, key: String) async -> T? {
        if let cached: T = await memory.read(T.self, key: key) {
            return cached
        }
        guard let disk else { return nil }
        if let cached: T = await disk.read(T.self, key: key) {
            // Promote to L1 with a generous default TTL; service-level TTL is
            // re-applied on the next write path.
            await memory.write(cached, key: key, ttl: 300)
            return cached
        }
        return nil
    }

    func write<T: Codable>(_ value: T, key: String, ttl: TimeInterval) async {
        await memory.write(value, key: key, ttl: ttl)
        await disk?.write(value, key: key, ttl: ttl)
    }

    func invalidate(prefix: String) async {
        await memory.invalidate(prefix: prefix)
        await disk?.invalidate(prefix: prefix)
    }

    func invalidateAll() async {
        await memory.invalidateAll()
        await disk?.invalidateAll()
    }
}
