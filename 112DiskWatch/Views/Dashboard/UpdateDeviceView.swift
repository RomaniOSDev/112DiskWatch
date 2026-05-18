//
//  UpdateDeviceView.swift
//  112DiskWatch
//

import SwiftUI

struct UpdateDeviceView: View {
    @ObservedObject var viewModel: DiskWatchViewModel
    let device: StorageDevice
    @Environment(\.dismiss) private var dismiss

    @State private var usedSpace: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                DiskScreenBackdrop()

                Form {
                    Section {
                        Text(device.name)
                            .foregroundColor(.gray)

                        HStack {
                            Text("Used (GB)")
                            Spacer()
                            TextField("", value: $usedSpace, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                        }

                        HStack {
                            Text("Free")
                            Spacer()
                            let cap = viewModel.devices.first(where: { $0.id == device.id })?.totalCapacity ?? device.totalCapacity
                            let free = max(0, cap - usedSpace)
                            Text("\(free) GB")
                                .foregroundColor(
                                    free < 10 ? .diskDanger : (free < 20 ? .diskWarning : .diskNormal)
                                )
                                .bold()
                        }
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle("Update data")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                usedSpace = viewModel.devices.first(where: { $0.id == device.id })?.usedSpace ?? device.usedSpace
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.diskNormal)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let current = viewModel.devices.first(where: { $0.id == device.id }) {
                            viewModel.updateDevice(current, newUsedSpace: usedSpace)
                        }
                        dismiss()
                    }
                    .bold()
                    .foregroundColor(.diskNormal)
                }
            }
        }
    }
}
