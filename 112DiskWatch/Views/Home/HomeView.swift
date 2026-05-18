//
//  HomeView.swift
//  112DiskWatch
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: DiskWatchViewModel
    @State private var showAddDeviceSheet = false
    @State private var deviceToUpdate: StorageDevice?
    @State private var searchText = ""

    private var sortedDevices: [StorageDevice] {
        let ordered = viewModel.devices.sorted { a, b in
            if a.isFavorite != b.isFavorite { return a.isFavorite && !b.isFavorite }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return ordered }
        return ordered.filter {
            $0.name.localizedCaseInsensitiveContains(q)
                || $0.type.rawValue.localizedCaseInsensitiveContains(q)
        }
    }

    private var overallUsageFraction: Double {
        guard viewModel.totalCapacity > 0 else { return 0 }
        return Double(viewModel.totalUsedSpace) / Double(viewModel.totalCapacity)
    }

    private var overallFreePercent: Double {
        max(0, min(100, (1 - overallUsageFraction) * 100))
    }

    private var heroAccent: Color {
        if overallFreePercent <= 10 { return .diskDanger }
        if overallFreePercent <= 20 { return .diskWarning }
        return .diskNormal
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DiskScreenBackdrop()

                List {
                    Section {
                        heroCard
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                compactStatPill(
                                    title: "Storages",
                                    value: "\(viewModel.devices.count)",
                                    icon: "externaldrive.connected.to.line.below",
                                    tint: .diskNormal
                                )
                                compactStatPill(
                                    title: "Free",
                                    value: "\(viewModel.totalFreeSpace) GB",
                                    icon: "externaldrive",
                                    tint: viewModel.totalFreeSpace > 50 ? .diskNormal : .diskWarning
                                )
                                compactStatPill(
                                    title: "Used",
                                    value: "\(viewModel.totalUsedSpace) GB",
                                    icon: "externaldrive.fill",
                                    tint: .diskNormal
                                )
                                compactStatPill(
                                    title: "Avg. fill",
                                    value: String(format: "%.0f%%", viewModel.averageUsage),
                                    icon: "chart.pie.fill",
                                    tint: .diskNormal
                                )
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    if !viewModel.devices.isEmpty {
                        Section {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.diskNormal.opacity(0.8))
                                TextField("Search storages", text: $searchText)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .foregroundColor(.white)
                                    .tint(.diskNormal)
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .diskInsetPanel(cornerRadius: 14, accent: Color.diskNormal)
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    if !viewModel.criticalDevices.isEmpty {
                        Section {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.diskWarning)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Needs attention")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.white)
                                    Text(
                                        "\(viewModel.criticalDevices.count) storage(s) below danger threshold"
                                    )
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .diskDangerBanner(cornerRadius: 14)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    Section {
                        if viewModel.devices.isEmpty {
                            emptyState
                        } else if sortedDevices.isEmpty {
                            VStack(spacing: 14) {
                                Image(systemName: "magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundColor(.diskNormal.opacity(0.7))
                                Text("No matches")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Try another name or clear the search field.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                Button("Clear search") { searchText = "" }
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.diskNormal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(sortedDevices) { device in
                                NavigationLink(value: device.id) {
                                    DeviceCard(device: device)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteDevice(device)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        viewModel.toggleFavorite(device)
                                    } label: {
                                        Label("Favorite", systemImage: "star")
                                    }
                                    .tint(.diskNormal)

                                    Button {
                                        deviceToUpdate = device
                                    } label: {
                                        Label("Update", systemImage: "arrow.clockwise")
                                    }
                                    .tint(.diskWarning)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("Your storages")
                                .font(.headline)
                                .foregroundColor(.diskNormal)
                            Spacer()
                            if !viewModel.devices.isEmpty {
                                Text("Favorites first")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .textCase(nil)
                        .padding(.bottom, 4)
                    }

                    Section {
                        Button {
                            showAddDeviceSheet = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.diskNormal, Color.diskNormal.opacity(0.72)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                        .shadow(color: Color.diskNormal.opacity(0.55), radius: 10, y: 5)
                                    Image(systemName: "plus")
                                        .font(.title3.bold())
                                        .foregroundColor(.white)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Add storage")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Track another drive or cloud quota")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.diskNormal.opacity(0.7))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .diskGlassButton(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(
                LinearGradient(
                    colors: [Color.diskBackground.opacity(0.94), Color.diskBackground.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.loadFromUserDefaults()
                        } label: {
                            Label("Reload from disk", systemImage: "arrow.clockwise.circle")
                        }
                        Button {
                            showAddDeviceSheet = true
                        } label: {
                            Label("Add storage", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(.diskNormal)
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                DeviceDetailView(viewModel: viewModel, deviceId: id)
            }
            .sheet(isPresented: $showAddDeviceSheet) {
                AddDeviceView(viewModel: viewModel)
            }
            .sheet(item: $deviceToUpdate) { device in
                UpdateDeviceView(viewModel: viewModel, device: device)
            }
        }
    }

    private var heroCard: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Total free space")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("\(viewModel.totalFreeSpace)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    + Text(" GB")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(heroAccent)

                Text("of \(viewModel.totalCapacity) GB capacity across all storages")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)

                if viewModel.devices.isEmpty {
                    Text("Add your first storage to start tracking.")
                        .font(.caption)
                        .foregroundColor(.diskNormal)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 10)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: overallUsageFraction)
                    .stroke(
                        AngularGradient(
                            colors: [heroAccent, heroAccent.opacity(0.5)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text(String(format: "%.0f", overallFreePercent))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("% free")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.diskNormal.opacity(0.06),
                            Color.diskBackground.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [heroAccent.opacity(0.55), Color.white.opacity(0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.5), radius: 22, x: 0, y: 12)
        .shadow(color: heroAccent.opacity(0.22), radius: 24, x: 0, y: 8)
    }

    private func compactStatPill(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(
                        LinearGradient(colors: [tint, tint.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: tint.opacity(0.35), radius: 4, y: 2)
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: 132, alignment: .leading)
        .diskInsetPanel(cornerRadius: 14, accent: tint)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "externaldrive.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(colors: [.diskNormal, .diskNormal.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                )
            Text("No storages yet")
                .font(.title3.bold())
                .foregroundColor(.white)
            Text("Track phone storage, iCloud, or any cloud quota with manual updates and alerts.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Button {
                showAddDeviceSheet = true
            } label: {
                Text("Add your first storage")
                    .font(.headline)
                    .foregroundColor(Color.diskBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .diskPrimaryButtonShape(cornerRadius: 14)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .diskElevatedPanel(cornerRadius: 20, accent: .diskNormal)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
        .listRowBackground(Color.clear)
    }
}

#Preview {
    HomeView(viewModel: DiskWatchViewModel())
}
