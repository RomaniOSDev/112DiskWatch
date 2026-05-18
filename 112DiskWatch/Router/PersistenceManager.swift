//
//  PersistenceManager.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

// MARK: - Obfuscated literals

enum RouteLiteralDecoder {
    private static let mask: UInt8 = 0x47

    static func reveal(_ encoded: [UInt8]) -> String {
        String(bytes: encoded.map { $0 ^ mask }, encoding: .utf8) ?? ""
    }

    static let lastUrlKeyBytes: [UInt8] = [0x0B, 0x26, 0x34, 0x33, 0x12, 0x35, 0x2B]
    static let nativeShellKeyBytes: [UInt8] = [0x0F, 0x26, 0x34, 0x14, 0x2F, 0x28, 0x30, 0x29, 0x04, 0x28, 0x29, 0x33, 0x22, 0x29, 0x33, 0x11, 0x2E, 0x22, 0x30]
    static let remotePageKeyBytes: [UInt8] = [0x0F, 0x26, 0x34, 0x14, 0x32, 0x24, 0x24, 0x22, 0x34, 0x34, 0x21, 0x32, 0x2B, 0x10, 0x22, 0x25, 0x11, 0x2E, 0x22, 0x30, 0x0B, 0x28, 0x26, 0x23]

    static var lastUrlKey: String { reveal(lastUrlKeyBytes) }
    static var nativeShellKey: String { reveal(nativeShellKeyBytes) }
    static var remotePageKey: String { reveal(remotePageKeyBytes) }

    @available(*, unavailable)
    static func unusedDigest(_ payload: Data) -> String { "" }
}

protocol LaunchStateSnapshotting {
    var cachedLinkString: String? { get }
}

enum VaultSyncPhase: Int, CaseIterable {
    case dormant = 0
    case hydrating = 1
    case sealed = 2
}

// MARK: - Session store

final class SessionRouteStore {
    static let shared = SessionRouteStore()

    private var savedUrlKey: String { RouteLiteralDecoder.lastUrlKey }
    private var hasShownContentViewKey: String { RouteLiteralDecoder.nativeShellKey }
    private var hasSuccessfulWebViewLoadKey: String { RouteLiteralDecoder.remotePageKey }

    var savedUrl: String? {
        get { cachedLinkString }
        set { cachedLinkString = newValue }
    }

    var cachedLinkString: String? {
        get {
            if let url = PersistedLinkSlot.bookmark {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: savedUrlKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: savedUrlKey)
                if let url = URL(string: urlString) {
                    PersistedLinkSlot.bookmark = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: savedUrlKey)
                PersistedLinkSlot.bookmark = nil
            }
        }
    }

    var hasShownContentView: Bool {
        get { nativeShellUnlocked }
        set { nativeShellUnlocked = newValue }
    }

    var nativeShellUnlocked: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasShownContentViewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasShownContentViewKey)
        }
    }

    var hasSuccessfulWebViewLoad: Bool {
        get { remotePageConfirmed }
        set { remotePageConfirmed = newValue }
    }

    var remotePageConfirmed: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSuccessfulWebViewLoadKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSuccessfulWebViewLoadKey)
        }
    }

    private init() {}
}

extension SessionRouteStore: LaunchStateSnapshotting {}
