//
//  StorageDevice+Status.swift
//  112DiskWatch
//

import SwiftUI

extension StorageDevice {
    var statusColor: Color {
        if freePercentage <= Double(dangerThreshold) {
            return .diskDanger
        } else if freePercentage <= Double(warningThreshold) {
            return .diskWarning
        } else {
            return .diskNormal
        }
    }

    var statusMessage: String {
        if freePercentage <= Double(dangerThreshold) {
            return "Critically low free space"
        } else if freePercentage <= Double(warningThreshold) {
            return "Low free space"
        } else {
            return "Enough free space"
        }
    }
}
