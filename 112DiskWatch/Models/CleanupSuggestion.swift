//
//  CleanupSuggestion.swift
//  112DiskWatch
//

import Foundation

struct CleanupSuggestion: Identifiable, Codable {
    let id: UUID
    var deviceId: UUID
    var title: String
    var description: String
    var potentialFreedSpace: Int
    var category: FileCategory
    var isCompleted: Bool
}
