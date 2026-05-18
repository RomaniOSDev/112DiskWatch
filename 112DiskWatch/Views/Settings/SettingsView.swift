//
//  SettingsView.swift
//  112DiskWatch
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DiskScreenBackdrop()

                List {
                    Section {
                        Button {
                            rateApp()
                        } label: {
                            Label {
                                Text("Rate Us")
                                    .foregroundColor(.white)
                            } icon: {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.diskWarning, .diskWarning.opacity(0.65)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                        }
                        .listRowBackground(rowBackground)

                        Button {
                            openExternalLink(.privacyPolicy)
                        } label: {
                            Label {
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                            } icon: {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundColor(.diskNormal)
                            }
                        }
                        .listRowBackground(rowBackground)

                        Button {
                            openExternalLink(.termsOfUse)
                        } label: {
                            Label {
                                Text("Terms of Use")
                                    .foregroundColor(.white)
                            } icon: {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.diskNormal)
                            }
                        }
                        .listRowBackground(rowBackground)
                    } header: {
                        Text("Support & legal")
                            .foregroundColor(.gray)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(
                LinearGradient(
                    colors: [Color.diskBackground.opacity(0.94), Color.diskBackground.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
        }
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.diskNormal.opacity(0.2), lineWidth: 1)
            )
    }

    private func openExternalLink(_ link: ExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    SettingsView()
}
