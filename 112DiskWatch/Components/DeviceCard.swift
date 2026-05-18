//
//  DeviceCard.swift
//  112DiskWatch
//

import SwiftUI

struct DeviceCard: View {
    let device: StorageDevice

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: device.type.icon)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [device.statusColor, device.statusColor.opacity(0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .font(.title2)
                    .shadow(color: device.statusColor.opacity(0.45), radius: 6, y: 3)

                VStack(alignment: .leading) {
                    HStack {
                        Text(device.name)
                            .foregroundColor(.white)
                            .font(.headline)

                        if device.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(
                                    LinearGradient(colors: [.diskNormal, .diskNormal.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                )
                                .font(.caption)
                                .shadow(color: Color.diskNormal.opacity(0.4), radius: 3, y: 1)
                        }
                    }

                    Text(device.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(device.statusMessage)
                        .font(.caption)
                        .foregroundColor(device.statusColor)

                    Text("Updated: \(formattedShortDate(device.lastUpdated))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Used")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    Text("\(device.usedSpace) GB of \(device.totalCapacity) GB")
                        .font(.caption)
                        .foregroundColor(.white)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.45), Color.black.opacity(0.25)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                            )

                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [device.statusColor, device.statusColor.opacity(0.65)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(4, geometry.size.width * CGFloat(device.usagePercentage / 100)),
                                height: 10
                            )
                            .shadow(color: device.statusColor.opacity(0.4), radius: 4, y: 2)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("Free: \(device.freeSpace) GB")
                        .font(.caption2)
                        .foregroundColor(device.statusColor)

                    Spacer()

                    Text("Thresholds: \(device.warningThreshold)% / \(device.dangerThreshold)%")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .diskElevatedPanel(cornerRadius: 16, accent: device.statusColor)
    }
}
