//
//  GoalsView.swift
//  112DiskWatch
//

import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: DiskWatchViewModel
    @State private var showAddGoalSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                DiskScreenBackdrop()

                List {
                    Section {
                        Text("Free-up goals")
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
                            .padding(.vertical, 8)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    ForEach(viewModel.goals) { goal in
                        GoalCard(goal: goal)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteGoal(goal)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                if !goal.isCompleted {
                                    Button {
                                        viewModel.completeGoal(goal)
                                    } label: {
                                        Label("Complete", systemImage: "checkmark")
                                    }
                                    .tint(.diskNormal)
                                }
                            }
                    }

                    Section {
                        Button {
                            showAddGoalSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "target")
                                    .foregroundStyle(
                                        LinearGradient(colors: [.diskNormal, .diskNormal.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                                    )
                                Text("Add goal")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(
                                        LinearGradient(colors: [.diskNormal, .diskNormal.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                    )
                            }
                            .foregroundColor(.white)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .diskGlassButton(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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
            .sheet(isPresented: $showAddGoalSheet) {
                AddGoalView(viewModel: viewModel)
            }
        }
    }
}
