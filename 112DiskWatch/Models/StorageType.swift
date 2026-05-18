//
//  StorageType.swift
//  112DiskWatch
//

import Foundation

enum StorageType: String, CaseIterable, Codable {
    case internalStorage = "Internal Storage"
    case icloud = "iCloud"
    case googleDrive = "Google Drive"
    case dropbox = "Dropbox"
    case oneDrive = "OneDrive"
    case external = "External Drive"
    case custom = "Other"

    var icon: String {
        switch self {
        case .internalStorage: return "internaldrive"
        case .icloud: return "icloud"
        case .googleDrive, .dropbox, .custom: return "folder"
        case .oneDrive: return "cloud"
        case .external: return "externaldrive"
        }
    }
}
