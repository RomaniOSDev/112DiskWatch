//
//  GoalCard.swift
//  112DiskWatch
//

import SwiftUI

struct GoalCard: View {
    let goal: StorageGoal

    private var accent: Color {
        goal.isCompleted ? .diskNormal : .diskNormal.opacity(0.85)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if goal.isCompleted {
                    Text("Done")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.diskNormal.opacity(0.35), Color.diskNormal.opacity(0.12)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.diskNormal.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.diskNormal)
                        .shadow(color: Color.diskNormal.opacity(0.25), radius: 6, y: 2)
                }
            }

            HStack {
                Text("Free space:")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(goal.currentFreeSpace)/\(goal.targetFreeSpace) GB")
                    .font(.caption)
                    .foregroundColor(.diskNormal)

                Spacer()

                ProgressView(value: goal.progress)
                    .tint(.diskNormal)
                    .frame(width: 100, height: 4)
            }

            if let deadline = goal.deadline {
                Text("by \(formattedShortDate(deadline))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .diskElevatedPanel(cornerRadius: 14, accent: accent)
    }
}
