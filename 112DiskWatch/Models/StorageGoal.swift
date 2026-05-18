//
//  StorageGoal.swift
//  112DiskWatch
//

import Foundation

struct StorageGoal: Identifiable, Codable {
    let id: UUID
    var name: String
    var targetFreeSpace: Int
    var currentFreeSpace: Int
    var deadline: Date?
    var isCompleted: Bool
    let createdAt: Date

    var progress: Double {
        guard targetFreeSpace > 0 else { return 0 }
        return min(Double(currentFreeSpace) / Double(targetFreeSpace), 1.0)
    }
}
