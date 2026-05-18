//
//  AlertThreshold.swift
//  112DiskWatch
//

import Foundation

enum AlertThreshold: String, CaseIterable, Codable {
    case warning = "Warning"
    case danger = "Danger"

    var percentage: Int {
        switch self {
        case .warning: return 20
        case .danger: return 10
        }
    }
}
