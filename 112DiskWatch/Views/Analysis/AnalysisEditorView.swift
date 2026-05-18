//
//  AnalysisEditorView.swift
//  112DiskWatch
//

import SwiftUI

struct AnalysisEditorView: View {
    @ObservedObject var viewModel: DiskWatchViewModel
    let device: StorageDevice
    @Environment(\.dismiss) private var dismiss

    @State private var values: [FileCategory: Int] = [:]
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ZStack {
                DiskScreenBackdrop()

                Form {
                    Section {
                        Text(device.name)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))

                    Section {
                        ForEach(FileCategory.allCases, id: \.self) { category in
                            HStack {
                                Label(category.rawValue, systemImage: category.icon)
                                    .foregroundColor(.white)
                                Spacer()
                                TextField(
                                    "0",
                                    value: Binding(
                                        get: { values[category] ?? 0 },
                                        set: { values[category] = $0 }
                                    ),
                                    format: .number
                                )
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 64)
                                .foregroundColor(.white)
                                Text("GB")
                                    .foregroundColor(.gray)
                            }
                        }
                    } header: {
                        Text("Size by category").foregroundColor(.gray)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))

                    Section {
                        TextEditor(text: $notes)
                            .frame(minHeight: 72)
                            .foregroundColor(.white)
                            .tint(.diskNormal)
                    } header: {
                        Text("Notes (optional)").foregroundColor(.gray)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle("Breakdown")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let existing = viewModel.analysis(for: device.id) {
                    values = existing.categories
                    notes = existing.notes ?? ""
                } else {
                    for c in FileCategory.allCases {
                        values[c] = values[c] ?? 0
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.diskNormal)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let filtered = values.filter { $0.value > 0 }
                        let analysis = StorageAnalysis(
                            id: UUID(),
                            deviceId: device.id,
                            date: Date(),
                            categories: Dictionary(uniqueKeysWithValues: filtered.map { ($0.key, $0.value) }),
                            notes: notes.isEmpty ? nil : notes
                        )
                        viewModel.setDeviceAnalysis(analysis)
                        dismiss()
                    }
                    .foregroundColor(.diskNormal)
                }
            }
        }
    }
}
