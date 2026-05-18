//
//  StorageHistory.swift
//  112DiskWatch
//

import Foundation

struct StorageHistory: Identifiable, Codable {
    let id: UUID
    let deviceId: UUID
    let date: Date
    var freeSpace: Int
}
