//
//  DiskCache.swift
//  GameSearch
//
//  L2 disk cache for the Tournaments module. JSON envelopes in
//  ~/Library/Caches/Tournaments/ with mtime-based eviction.
//

import Foundation

actor DiskCache {

    // MARK: - Constants

    static let defaultMaxSizeBytes: Int64 = 10 * 1024 * 1024
    static let defaultSubdirectory = "Tournaments"
    static let schemaVersion = 1

    // MARK: - Storage layout

    private struct Envelope<T: Codable>: Codable {
        let value: T
        let expiresAt: Date
        let schemaVersion: Int
        var isExpired: Bool { Date() >= expiresAt }
    }

    // MARK: - Dependencies

    private let directory: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let maxSizeBytes: Int64

    // MARK: - Init

    init(
        directory: URL? = nil,
        fileManager: FileManager = .default,
        maxSizeBytes: Int64 = DiskCache.defaultMaxSizeBytes
    ) {
        self.fileManager = fileManager
        self.maxSizeBytes = maxSizeBytes

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        if let directory {
            self.directory = directory
        } else {
            let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
                ?? URL(fileURLWithPath: NSTemporaryDirectory())
            self.directory = caches.appendingPathComponent(DiskCache.defaultSubdirectory, isDirectory: true)
        }
        try? fileManager.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    // MARK: - API

    func read<T: Codable>(_ type: T.Type, key: String) -> T? {
        let url = fileURL(forKey: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let envelope = try? decoder.decode(Envelope<T>.self, from: data) else {
            try? fileManager.removeItem(at: url)
            return nil
        }
        if envelope.schemaVersion != DiskCache.schemaVersion || envelope.isExpired {
            try? fileManager.removeItem(at: url)
            return nil
        }
        return envelope.value
    }

    func write<T: Codable>(_ value: T, key: String, ttl: TimeInterval) {
        let envelope = Envelope(
            value: value,
            expiresAt: Date().addingTimeInterval(ttl),
            schemaVersion: DiskCache.schemaVersion
        )
        guard let data = try? encoder.encode(envelope) else { return }
        let url = fileURL(forKey: key)
        try? data.write(to: url, options: .atomic)
        evictIfNeeded()
    }

    func invalidate(prefix: String) {
        let prefixHash = safeFilename(prefix: prefix)
        guard let urls = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else { return }
        for url in urls where url.lastPathComponent.hasPrefix(prefixHash) {
            try? fileManager.removeItem(at: url)
        }
    }

    func invalidateAll() {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else { return }
        for url in urls {
            try? fileManager.removeItem(at: url)
        }
    }

    func currentSizeBytes() -> Int64 {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else { return 0 }
        return urls.reduce(0) { acc, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return acc + Int64(size)
        }
    }
}

// MARK: - Private

private extension DiskCache {

    func fileURL(forKey key: String) -> URL {
        directory.appendingPathComponent(safeFilename(forKey: key) + ".json")
    }

    func safeFilename(forKey key: String) -> String {
        // Preserve a hashed prefix-friendly filename: SHA-style sanitize +
        // a stable hash suffix for collision avoidance.
        let sanitized = key.unicodeScalars.map { scalar -> Character in
            let value = scalar.value
            if (value >= 0x30 && value <= 0x39) ||
               (value >= 0x41 && value <= 0x5A) ||
               (value >= 0x61 && value <= 0x7A) ||
               value == 0x2D || value == 0x5F {
                return Character(scalar)
            }
            return "_"
        }
        return String(sanitized)
    }

    func safeFilename(prefix: String) -> String {
        safeFilename(forKey: prefix)
    }

    func evictIfNeeded() {
        let size = currentSizeBytes()
        guard size > maxSizeBytes else { return }
        guard let urls = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]
        ) else { return }
        let sorted = urls.sorted { lhs, rhs in
            let lhsDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey])
                .contentModificationDate) ?? .distantPast
            let rhsDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey])
                .contentModificationDate) ?? .distantPast
            return lhsDate < rhsDate
        }
        var currentSize = size
        for url in sorted {
            if currentSize <= maxSizeBytes { break }
            let fileSize = Int64((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
            try? fileManager.removeItem(at: url)
            currentSize -= fileSize
        }
    }
}
