//
//  OnboardingView.swift
//  112DiskWatch
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("diskwatch_has_completed_onboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbol: "externaldrive.connected.to.line.below",
            symbolColors: [Color.diskNormal, Color.diskNormal.opacity(0.55)],
            title: "Track every storage",
            text: "Add phones, cloud drives, or external disks. Enter totals and used space yourself—no network required."
        ),
        OnboardingPage(
            symbol: "exclamationmark.triangle.fill",
            symbolColors: [Color.diskWarning, Color.diskWarning.opacity(0.55)],
            title: "Alerts that match your rules",
            text: "Set free-space thresholds. Yellow means tight; red means critical—so you always know when to act."
        ),
        OnboardingPage(
            symbol: "chart.xyaxis.line",
            symbolColors: [Color.diskNormal, Color.diskWarning.opacity(0.8)],
            title: "Analyze, plan, improve",
            text: "Break down categories, try cleanup ideas, set free-space goals, and watch trends over time."
        )
    ]

    var body: some View {
        ZStack {
            DiskScreenBackdrop()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        finishOnboarding()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.diskNormal)
                    .padding(.trailing, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 18) {
                    HStack(spacing: 10) {
                        ForEach(0 ..< pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.diskNormal : Color.white.opacity(0.2))
                                .frame(width: index == currentPage ? 28 : 8, height: 8)
                                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentPage)
                        }
                    }

                    HStack(alignment: .center) {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                currentPage = max(0, currentPage - 1)
                            }
                        } label: {
                            Text("Back")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(currentPage > 0 ? .white.opacity(0.85) : .clear)
                        }
                        .disabled(currentPage == 0)
                        .frame(width: 72, alignment: .leading)

                        Spacer()

                        Button {
                            if currentPage >= pages.count - 1 {
                                finishOnboarding()
                            } else {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                    currentPage = min(pages.count - 1, currentPage + 1)
                                }
                            }
                        } label: {
                            Text(currentPage >= pages.count - 1 ? "Get started" : "Next")
                                .font(.headline)
                                .foregroundColor(Color.diskBackground)
                                .padding(.horizontal, 26)
                                .padding(.vertical, 14)
                                .diskPrimaryButtonShape(cornerRadius: 14)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .padding(.top, 8)
            }
        }
    }

    private func finishOnboarding() {
        hasCompletedOnboarding = true
    }
}

private struct OnboardingPage {
    let symbol: String
    let symbolColors: [Color]
    let title: String
    let text: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [page.symbolColors[0].opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                Image(systemName: page.symbol)
                    .font(.system(size: 72, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: page.symbolColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: page.symbolColors[0].opacity(0.45), radius: 16, y: 8)
                    .padding(36)
                    .diskElevatedPanel(cornerRadius: 32, accent: page.symbolColors[0])
            }

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.88)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 4, y: 2)

                Text(page.text)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    OnboardingView()
}
