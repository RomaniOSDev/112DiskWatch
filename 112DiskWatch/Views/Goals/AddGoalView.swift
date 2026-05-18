//
//  AddGoalView.swift
//  112DiskWatch
//

import SwiftUI

struct AddGoalView: View {
    @ObservedObject var viewModel: DiskWatchViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var targetFreeSpace = 10
    @State private var hasDeadline = false
    @State private var deadline = Date().addingTimeInterval(86400 * 14)

    var body: some View {
        NavigationStack {
            ZStack {
                DiskScreenBackdrop()

                Form {
                    Section {
                        TextField("Goal name", text: $name)
                            .foregroundColor(.white)
                            .tint(.diskNormal)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))

                    Section {
                        HStack {
                            Text("Target free space (GB)")
                            Spacer()
                            TextField("", value: $targetFreeSpace, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 64)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                        }

                        Text("Current total free: \(viewModel.totalFreeSpace) GB")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))

                    Section {
                        Toggle("Deadline", isOn: $hasDeadline)
                            .tint(.diskNormal)

                        if hasDeadline {
                            DatePicker("Date", selection: $deadline, displayedComponents: .date)
                                .foregroundColor(.white)
                                .tint(.diskNormal)
                        }
                    }
                    .listRowBackground(Color.diskBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle("New goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.diskNormal)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let goal = StorageGoal(
                            id: UUID(),
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            targetFreeSpace: max(1, targetFreeSpace),
                            currentFreeSpace: viewModel.totalFreeSpace,
                            deadline: hasDeadline ? deadline : nil,
                            isCompleted: false,
                            createdAt: Date()
                        )
                        viewModel.addGoal(goal)
                        dismiss()
                    }
                    .foregroundColor(.diskNormal)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
