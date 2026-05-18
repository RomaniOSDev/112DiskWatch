//
//  ContentView.swift
//  112DiskWatch
//
//  Created by Роман Главацкий on 04.04.2026.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("diskwatch_has_completed_onboarding") private var hasCompletedOnboarding = false
    @StateObject private var viewModel = DiskWatchViewModel()
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabs
            } else {
                OnboardingView()
            }
        }
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            AnalysisView(viewModel: viewModel)
                .tabItem {
                    Label("Analysis", systemImage: "chart.pie.fill")
                }
                .tag(1)

            GoalsView(viewModel: viewModel)
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(2)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.diskNormal)
        .onAppear {
            viewModel.loadFromUserDefaults()
            applyTabBarAppearance()
        }
    }

    private func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.07, alpha: 0.94)

        let normal = UIColor.lightGray.withAlphaComponent(0.85)
        let selected = UIColor(red: 0.004, green: 0.573, blue: 0.996, alpha: 1)

        let item = appearance.stackedLayoutAppearance
        item.normal.iconColor = normal
        item.normal.titleTextAttributes = [.foregroundColor: normal]
        item.selected.iconColor = selected
        item.selected.titleTextAttributes = [.foregroundColor: selected]

        appearance.shadowColor = UIColor.black.withAlphaComponent(0.5)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
