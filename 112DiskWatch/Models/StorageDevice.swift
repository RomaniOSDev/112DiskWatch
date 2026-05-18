//
//  StorageDevice.swift
//  112DiskWatch
//

import Foundation

struct StorageDevice: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: StorageType
    var totalCapacity: Int
    var usedSpace: Int
    var warningThreshold: Int
    var dangerThreshold: Int
    var lastUpdated: Date
    var notes: String?
    var isFavorite: Bool
    let createdAt: Date

    var freeSpace: Int {
        max(0, totalCapacity - usedSpace)
    }

    var usagePercentage: Double {
        guard totalCapacity > 0 else { return 0 }
        return Double(usedSpace) / Double(totalCapacity) * 100
    }

    var freePercentage: Double {
        100 - usagePercentage
    }
}
