//
//  StatsView.swift
//  112DiskWatch
//

import Charts
import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: DiskWatchViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                DiskScreenBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Text("Statistics")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.diskNormal, .diskNormal.opacity(0.78)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color.diskNormal.opacity(0.3), radius: 8, y: 4)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            StatCard(
                                title: "Storages",
                                value: "\(viewModel.devices.count)",
                                icon: "externaldrive.connected.to.line.below",
                                color: .diskNormal
                            )

                            StatCard(
                                title: "Total capacity",
                                value: "\(viewModel.totalCapacity) GB",
                                icon: "externaldrive",
                                color: .diskNormal
                            )

                            StatCard(
                                title: "Free",
                                value: "\(viewModel.totalFreeSpace) GB",
                                icon: "checkmark.circle.fill",
                                color: viewModel.totalFreeSpacePercentage > 30 ? .diskNormal : .diskWarning
                            )

                            StatCard(
                                title: "Best gain",
                                value: "\(viewModel.biggestCleanup) GB",
                                icon: "trophy.fill",
                                color: .diskWarning
                            )
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Needs attention")
                                .font(.headline)
                                .foregroundColor(.diskDanger)
                                .shadow(color: Color.diskDanger.opacity(0.35), radius: 6, y: 2)

                            if viewModel.criticalDevices.isEmpty {
                                Text("Nothing critical right now.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.criticalDevices) { device in
                                    HStack {
                                        Image(systemName: device.type.icon)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [device.statusColor, device.statusColor.opacity(0.55)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .shadow(color: device.statusColor.opacity(0.35), radius: 4, y: 2)

                                        Text(device.name)
                                            .foregroundColor(.white)

                                        Spacer()

                                        Text("\(device.freeSpace) GB free")
                                            .foregroundColor(device.statusColor)
                                            .bold()
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                        .padding(18)
                        .diskDangerBanner(cornerRadius: 16)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Free space trend")
                                .font(.headline)
                                .foregroundColor(.diskNormal)
                                .shadow(color: Color.diskNormal.opacity(0.2), radius: 4, y: 1)

                            let series = viewModel.globalHistory
                            if series.count >= 2 {
                                Chart {
                                    ForEach(Array(series.enumerated()), id: \.offset) { _, item in
                                        LineMark(
                                            x: .value("Date", item.date),
                                            y: .value("Free GB", item.totalFree)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.diskNormal, .diskNormal.opacity(0.55)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    }
                                }
                                .frame(height: 170)
                            } else {
                                Text("Record more history entries to see a trend.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(18)
                        .diskElevatedPanel(cornerRadius: 16, accent: .diskNormal)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(
                LinearGradient(
                    colors: [Color.diskBackground.opacity(0.94), Color.diskBackground.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
        }
    }
}
