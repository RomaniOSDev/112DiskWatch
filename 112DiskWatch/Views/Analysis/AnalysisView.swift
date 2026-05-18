//
//  AnalysisView.swift
//  112DiskWatch
//

import SwiftUI

struct AnalysisView: View {
    @ObservedObject var viewModel: DiskWatchViewModel
    @State private var selectedDevice: StorageDevice?
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            ZStack {
                DiskScreenBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Text("Storage analysis")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.diskNormal, .diskNormal.opacity(0.75)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color.diskNormal.opacity(0.35), radius: 8, y: 4)
                            .padding(.horizontal)

                        devicePicker
                            .padding(.horizontal)

                        if let device = selectedDevice ?? viewModel.devices.first {
                            if let analysis = viewModel.analysis(for: device.id) {
                                distributionSection(device: device, analysis: analysis)
                                    .padding(.horizontal)

                                Button {
                                    showEditor = true
                                } label: {
                                    Text("Edit breakdown")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .foregroundColor(.diskNormal)
                                        .diskGlassButton(cornerRadius: 14)
                                }
                                .padding(.horizontal)
                            } else {
                                Text("No breakdown yet. Tap below to add sizes by category.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)

                                Button {
                                    showEditor = true
                                } label: {
                                    Text("Add breakdown")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .foregroundColor(Color.diskBackground)
                                        .diskPrimaryButtonShape(cornerRadius: 14)
                                }
                                .padding(.horizontal)
                            }

                            suggestionsSection(device: device)
                                .padding(.horizontal)
                        } else {
                            Text("Add a storage on the Home tab first.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(18)
                                .frame(maxWidth: .infinity)
                                .diskInsetPanel(cornerRadius: 16, accent: Color.diskNormal.opacity(0.4))
                                .padding(.horizontal)
                        }
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
            .onAppear {
                if selectedDevice == nil {
                    selectedDevice = viewModel.devices.first
                }
            }
            .onChange(of: viewModel.devices) { newList in
                if let id = selectedDevice?.id, newList.first(where: { $0.id == id }) == nil {
                    selectedDevice = newList.first
                }
            }
            .sheet(isPresented: $showEditor) {
                if let device = selectedDevice ?? viewModel.devices.first {
                    AnalysisEditorView(viewModel: viewModel, device: device)
                }
            }
        }
    }

    private var devicePicker: some View {
        Menu {
            ForEach(viewModel.devices) { device in
                Button(device.name) {
                    selectedDevice = device
                }
            }
        } label: {
            HStack {
                Text((selectedDevice ?? viewModel.devices.first)?.name ?? "Select storage")
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundStyle(
                        LinearGradient(colors: [.diskNormal, .diskNormal.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    )
            }
            .padding(16)
            .diskElevatedPanel(cornerRadius: 14, accent: .diskNormal)
        }
        .disabled(viewModel.devices.isEmpty)
    }

    @ViewBuilder
    private func distributionSection(device: StorageDevice, analysis: StorageAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data distribution")
                .font(.headline)
                .foregroundColor(.diskNormal)
                .shadow(color: Color.diskNormal.opacity(0.2), radius: 4, y: 1)

            ForEach(FileCategory.allCases, id: \.self) { category in
                let size = analysis.categories[category] ?? 0
                if size > 0 {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(
                                LinearGradient(colors: [.diskNormal, .diskNormal.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 30)
                            .shadow(color: Color.diskNormal.opacity(0.25), radius: 3, y: 1)

                        Text(category.rawValue)
                            .foregroundColor(.white)

                        Spacer()

                        Text("\(size) GB")
                            .foregroundColor(.diskNormal)
                            .bold()
                    }
                    .padding(.vertical, 4)

                    let percentage = Double(size) / Double(max(device.totalCapacity, 1)) * 100
                    ProgressView(value: percentage / 100)
                        .tint(.diskNormal)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.35))
                        )
                }
            }
        }
        .padding(16)
        .diskElevatedPanel(cornerRadius: 16, accent: .diskNormal)
    }

    @ViewBuilder
    private func suggestionsSection(device: StorageDevice) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Suggestions")
                    .font(.headline)
                    .foregroundColor(.diskNormal)
                    .shadow(color: Color.diskNormal.opacity(0.2), radius: 4, y: 1)
                Spacer()
                Button("Refresh") {
                    viewModel.generateSuggestions(for: device)
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(.diskBackground)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .diskPrimaryButtonShape(cornerRadius: 10)
            }

            let list = viewModel.suggestions(for: device.id)
            if list.isEmpty {
                Text("No suggestions. Tap Refresh to generate ideas.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                VStack(spacing: 12) {
                    ForEach(list) { suggestion in
                        HStack(alignment: .center, spacing: 8) {
                            SuggestionCard(suggestion: suggestion)
                            if !suggestion.isCompleted {
                                Button {
                                    viewModel.completeSuggestion(suggestion)
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(
                                            LinearGradient(colors: [.diskNormal, .diskNormal.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                                        )
                                        .shadow(color: Color.diskNormal.opacity(0.45), radius: 6, y: 3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .diskElevatedPanel(cornerRadius: 16, accent: Color.diskWarning.opacity(0.5))
    }
}
