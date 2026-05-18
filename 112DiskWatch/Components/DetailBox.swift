//
//  DetailBox.swift
//  112DiskWatch
//

import SwiftUI

struct DetailBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .font(.title2)
                .shadow(color: color.opacity(0.3), radius: 6, y: 3)

            Text(value)
                .foregroundColor(.white)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .diskElevatedPanel(cornerRadius: 12, accent: color)
    }
}
