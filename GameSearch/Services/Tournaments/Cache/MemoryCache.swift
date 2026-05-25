//
//  MemoryCache.swift
//  GameSearch
//
//  L1 in-memory cache (NSCache-backed) for the Tournaments module.
//

import Foundation

actor MemoryCache {

    // MARK: - Limits

    static let defaultTotalCostLimitBytes: Int = 50 * 1024 * 1024
    static let defaultCountLimit: Int = 500

    // MARK: - Storage

    private final class Entry {
        let value: Any
        let expiresAt: Date
        let cost: Int
        init(value: Any, expiresAt: Date, cost: Int) {
            self.value = value
            self.expiresAt = expiresAt
            self.cost = cost
        }
        var isExpired: Bool { Date() >= expiresAt }
    }

    private let cache: NSCache<NSString, Entry>
    private var trackedKeys: Set<String> = []

    // MARK: - Init

    init(
        totalCostLimitBytes: Int = MemoryCache.defaultTotalCostLimitBytes,
        countLimit: Int = MemoryCache.defaultCountLimit
    ) {
        let storage = NSCache<NSString, Entry>()
        storage.totalCostLimit = totalCostLimitBytes
        storage.countLimit = countLimit
        self.cache = storage
    }

    // MARK: - API

    func read<T>(_ type: T.Type, key: String) -> T? {
        guard let entry = cache.object(forKey: key as NSString) else { return nil }
        if entry.isExpired {
            cache.removeObject(forKey: key as NSString)
            trackedKeys.remove(key)
            return nil
        }
        return entry.value as? T
    }

    func write<T>(_ value: T, key: String, ttl: TimeInterval, approximateCost: Int = 1024) {
        let entry = Entry(
            value: value,
            expiresAt: Date().addingTimeInterval(ttl),
            cost: approximateCost
        )
        cache.setObject(entry, forKey: key as NSString, cost: approximateCost)
        trackedKeys.insert(key)
    }

    func invalidate(prefix: String) {
        let matching = trackedKeys.filter { $0.hasPrefix(prefix) }
        for key in matching {
            cache.removeObject(forKey: key as NSString)
            trackedKeys.remove(key)
        }
    }

    func invalidateAll() {
        cache.removeAllObjects()
        trackedKeys.removeAll()
    }

    func count() -> Int {
        trackedKeys.count
    }
}
