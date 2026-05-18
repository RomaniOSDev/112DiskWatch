//
//  ExternalLink.swift
//  112DiskWatch
//

import Foundation

enum ExternalLink {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://www.termsfeed.com/live/9525bcc4-da06-44c6-b63f-d2b65200bb2f"
        case .termsOfUse:
            return "https://www.termsfeed.com/live/3d5a0da8-a5e3-4a27-ad54-4a549ba9eb33"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
