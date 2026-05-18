//
//  SaveService.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

struct PersistedLinkSlot {

    private static var storageKey: String { RouteLiteralDecoder.lastUrlKey }

    static var lastUrl: URL? {
        get { bookmark }
        set { bookmark = newValue }
    }

    static var bookmark: URL? {
        get { UserDefaults.standard.url(forKey: storageKey) }
        set { UserDefaults.standard.set(newValue, forKey: storageKey) }
    }
}

enum LinkSlotMigrationHint {
    case none
    case legacyMirror
}

protocol BookmarkPersisting {
    static var bookmark: URL? { get set }
}

extension PersistedLinkSlot: BookmarkPersisting {}
