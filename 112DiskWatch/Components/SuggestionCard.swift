//
//  SuggestionCard.swift
//  112DiskWatch
//

import SwiftUI

struct SuggestionCard: View {
    let suggestion: CleanupSuggestion

    var body: some View {
        HStack {
            Image(systemName: suggestion.category.icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.diskWarning, Color.diskWarning.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .font(.title2)
                .shadow(color: Color.diskWarning.opacity(0.35), radius: 5, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .foregroundColor(.white)
                    .font(.headline)

                Text(suggestion.description)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("Up to +\(suggestion.potentialFreedSpace) GB")
                    .font(.caption2)
                    .foregroundColor(.diskWarning)
            }

            Spacer()

            if suggestion.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(
                        LinearGradient(colors: [.diskNormal, .diskNormal.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: Color.diskNormal.opacity(0.4), radius: 4, y: 2)
            }
        }
        .padding()
        .diskInsetPanel(cornerRadius: 12, accent: Color.diskWarning.opacity(0.45))
    }
}
