//
//  StorageAnalysis.swift
//  112DiskWatch
//

import Foundation

struct StorageAnalysis: Identifiable, Codable {
    let id: UUID
    let deviceId: UUID
    let date: Date
    var categories: [FileCategory: Int]
    var notes: String?
}
