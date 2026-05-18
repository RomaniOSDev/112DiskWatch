//
//  DeviceDetailView.swift
//  112DiskWatch
//

import Charts
import SwiftUI

struct DeviceDetailView: View {
    @ObservedObject var viewModel: DiskWatchViewModel
    let deviceId: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var showUpdateSheet = false
    @State private var showDeleteConfirmation = false

    private var device: StorageDevice? {
        viewModel.devices.first { $0.id == deviceId }
    }

    var body: some View {
        ZStack {
            DiskScreenBackdrop()

            if let device {
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 10) {
                            Image(systemName: device.type.icon)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [device.statusColor, device.statusColor.opacity(0.55)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .font(.system(size: 56))
                                .shadow(color: device.statusColor.opacity(0.5), radius: 12, y: 6)

                            Text(device.name)
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.45), radius: 4, y: 2)

                            Text(device.type.rawValue)
                                .font(.headline)
                                .foregroundColor(.gray)

                            Text(device.statusMessage)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(device.statusColor)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .diskElevatedPanel(cornerRadius: 20, accent: device.statusColor)

                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [device.statusColor.opacity(0.15), Color.clear],
                                        center: .center,
                                        startRadius: 40,
                                        endRadius: 120
                                    )
                                )
                                .frame(width: 220, height: 220)

                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.black.opacity(0.5), Color.white.opacity(0.06)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 22
                                )
                                .frame(width: 180, height: 180)
                                .shadow(color: Color.black.opacity(0.55), radius: 12, y: 6)

                            Circle()
                                .trim(from: 0, to: device.usagePercentage / 100)
                                .stroke(
                                    AngularGradient(
                                        colors: [device.statusColor, device.statusColor.opacity(0.45)],
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 22, lineCap: .round)
                                )
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                                .shadow(color: device.statusColor.opacity(0.45), radius: 10, y: 4)

                            VStack(spacing: 2) {
                                Text("\(Int(device.usagePercentage))%")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Text("used")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            DetailBox(
                                title: "Total",
                                value: "\(device.totalCapacity) GB",
                                icon: "externaldrive",
                                color: .diskNormal
                            )

                            DetailBox(
                                title: "Used",
                                value: "\(device.usedSpace) GB",
                                icon: "externaldrive.fill",
                                color: device.statusColor
                            )

                            DetailBox(
                                title: "Free",
                                value: "\(device.freeSpace) GB",
                                icon: "externaldrive.badge.checkmark",
                                color: device.freeSpace < 10 ? .diskDanger : (device.freeSpace < 20 ? .diskWarning : .diskNormal)
                            )

                            DetailBox(
                                title: "Last update",
                                value: formattedDate(device.lastUpdated),
                                icon: "clock",
                                color: Color.diskNormal.opacity(0.45)
                            )
                        }
                        .padding(.horizontal)

                        if let notes = device.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .diskInsetPanel(cornerRadius: 14, accent: Color.diskNormal.opacity(0.35))
                                .padding(.horizontal)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Free space history")
                                .font(.headline)
                                .foregroundColor(.diskNormal)
                                .shadow(color: Color.diskNormal.opacity(0.25), radius: 4, y: 1)

                            let rows = viewModel.history(for: device.id)
                            if rows.count >= 2 {
                                Chart {
                                    ForEach(rows) { item in
                                        LineMark(
                                            x: .value("Date", item.date),
                                            y: .value("Free GB", item.freeSpace)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.diskNormal, .diskNormal.opacity(0.6)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )

                                        AreaMark(
                                            x: .value("Date", item.date),
                                            y: .value("Free GB", item.freeSpace)
                                        )
                                        .foregroundStyle(Color.diskNormal.opacity(0.22))
                                    }
                                }
                                .frame(height: 160)
                            } else {
                                Text("Add more updates to see a chart.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(16)
                        .diskElevatedPanel(cornerRadius: 16, accent: .diskNormal)
                        .padding(.horizontal)

                        HStack(spacing: 12) {
                            Button {
                                showUpdateSheet = true
                            } label: {
                                Text("Update data")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .foregroundColor(Color.diskBackground)
                                    .diskPrimaryButtonShape(cornerRadius: 12)
                            }

                            Button {
                                showDeleteConfirmation = true
                            } label: {
                                Text("Delete")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .foregroundColor(.diskDanger)
                                    .diskOutlinedButtonShape(cornerRadius: 12, color: .diskDanger)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .padding(.vertical, 8)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "externaldrive.trianglebadge.exclamationmark")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(colors: [.gray, .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                        )
                    Text("Not found")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("This storage was removed.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(24)
                .diskElevatedPanel(cornerRadius: 18, accent: .diskNormal.opacity(0.3))
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showUpdateSheet) {
            if let d = viewModel.devices.first(where: { $0.id == deviceId }) {
                UpdateDeviceView(viewModel: viewModel, device: d)
            }
        }
        .alert("Delete storage?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let d = device {
                    viewModel.deleteDevice(d)
                }
                dismiss()
            }
        } message: {
            Text("This cannot be undone.")
        }
        .onChange(of: viewModel.devices) { newDevices in
            if !newDevices.contains(where: { $0.id == deviceId }) {
                dismiss()
            }
        }
    }
}
