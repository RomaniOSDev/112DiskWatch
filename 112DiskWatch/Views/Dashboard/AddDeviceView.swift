//
//  AddDeviceView.swift
//  112DiskWatch
//

import SwiftUI

struct AddDeviceView: View {
    @ObservedObject var viewModel: DiskWatchViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: StorageType = .internalStorage
    @State private var totalCapacity = 128
    @State private var usedSpace = 64
    @State private var warningThreshold = 20
    @State private var dangerThreshold = 10
    @State private var notes = ""
    @State private var isFavorite = false

    private var freeSpace: Int {
        max(0, totalCapacity - usedSpace)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DiskScreenBackdrop()

                Form {
                    Section {
                        TextField("Name", text: $name)
                            .foregroundColor(.white)
                            .tint(.diskNormal)

                        Picker("Storage type", selection: $type) {
                            ForEach(StorageType.allCases, id: \.self) { t in
                                Label(t.rawValue, systemImage: t.icon).tag(t)
                            }
                        }
                        .tint(.diskNormal)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))

                    Section {
                        HStack {
                            Text("Total (GB)")
                            Spacer()
                            TextField("", value: $totalCapacity, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                        }

                        HStack {
                            Text("Used (GB)")
                            Spacer()
                            TextField("", value: $usedSpace, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                        }

                        if totalCapacity > 0 {
                            HStack {
                                Text("Free")
                                Spacer()
                                Text("\(freeSpace) GB")
                                    .foregroundColor(
                                        freeSpace < 10 ? .diskDanger : (freeSpace < 20 ? .diskWarning : .diskNormal)
                                    )
                                    .bold()
                            }
                        }
                    } header: {
                        Text("Capacity").foregroundColor(.gray)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))

                    Section {
                        HStack {
                            Text("Yellow when free below")
                            Spacer()
                            Picker("", selection: $warningThreshold) {
                                ForEach(10 ... 30, id: \.self) { value in
                                    Text("\(value)%").tag(value)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.diskNormal)
                        }

                        HStack {
                            Text("Red when free below")
                            Spacer()
                            Picker("", selection: $dangerThreshold) {
                                ForEach(5 ... 15, id: \.self) { value in
                                    Text("\(value)%").tag(value)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.diskNormal)
                        }
                    } header: {
                        Text("Alert thresholds (free %)").foregroundColor(.gray)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))

                    Section {
                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .foregroundColor(.white)
                            .tint(.diskNormal)
                    } header: {
                        Text("Notes").foregroundColor(.gray)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))

                    Section {
                        Toggle("Add to favorites", isOn: $isFavorite)
                            .tint(.diskNormal)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle("New storage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.diskNormal)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                        .foregroundColor(.diskNormal)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || totalCapacity <= 0)
                }
            }
        }
    }

    private func save() {
        let used = max(0, min(usedSpace, totalCapacity))
        let device = StorageDevice(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            totalCapacity: totalCapacity,
            usedSpace: used,
            warningThreshold: warningThreshold,
            dangerThreshold: dangerThreshold,
            lastUpdated: Date(),
            notes: notes.isEmpty ? nil : notes,
            isFavorite: isFavorite,
            createdAt: Date()
        )
        viewModel.addDevice(device)
        dismiss()
    }
}
