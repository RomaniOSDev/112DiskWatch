//
//  FileCategory.swift
//  112DiskWatch
//

import Foundation

enum FileCategory: String, CaseIterable, Codable {
    case photos = "Photos & Video"
    case apps = "Apps"
    case documents = "Documents"
    case music = "Music"
    case downloads = "Downloads"
    case system = "System"
    case other = "Other"

    var icon: String {
        switch self {
        case .photos: return "photo.fill"
        case .apps: return "square.grid.2x2.fill"
        case .documents: return "doc.fill"
        case .music: return "music.note"
        case .downloads: return "arrow.down.circle.fill"
        case .system: return "gear"
        case .other: return "questionmark"
        }
    }
}
