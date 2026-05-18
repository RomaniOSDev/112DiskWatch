//
//  DiskWatchViewModel.swift
//  112DiskWatch
//

import Combine
import Foundation

@MainActor
final class DiskWatchViewModel: ObservableObject {
    @Published var devices: [StorageDevice] = []
    @Published var analyses: [StorageAnalysis] = []
    @Published var suggestions: [CleanupSuggestion] = []
    @Published var goals: [StorageGoal] = []
    @Published var history: [StorageHistory] = []

    var totalCapacity: Int {
        devices.reduce(0) { $0 + $1.totalCapacity }
    }

    var totalUsedSpace: Int {
        devices.reduce(0) { $0 + $1.usedSpace }
    }

    var totalFreeSpace: Int {
        devices.reduce(0) { $0 + $1.freeSpace }
    }

    var totalFreeSpacePercentage: Double {
        guard totalCapacity > 0 else { return 0 }
        return Double(totalFreeSpace) / Double(totalCapacity) * 100
    }

    var averageUsage: Double {
        guard !devices.isEmpty else { return 0 }
        return devices.reduce(0) { $0 + $1.usagePercentage } / Double(devices.count)
    }

    var criticalDevices: [StorageDevice] {
        devices.filter { $0.freePercentage <= Double($0.dangerThreshold) }
    }

    var biggestCleanup: Int {
        var maxGain = 0
        let byDevice = Dictionary(grouping: history, by: \.deviceId)
        for (_, entries) in byDevice {
            let sorted = entries.sorted { $0.date < $1.date }
            for i in 1..<sorted.count {
                let gain = sorted[i].freeSpace - sorted[i - 1].freeSpace
                if gain > maxGain { maxGain = gain }
            }
        }
        return maxGain
    }

    func analysis(for deviceId: UUID) -> StorageAnalysis? {
        analyses
            .filter { $0.deviceId == deviceId }
            .sorted { $0.date < $1.date }
            .last
    }

    var globalHistory: [(date: Date, totalFree: Int)] {
        let grouped = Dictionary(grouping: history, by: { Calendar.current.startOfDay(for: $0.date) })
        return grouped.map { date, items in
            (date: date, totalFree: items.reduce(0) { $0 + $1.freeSpace })
        }
        .sorted { $0.date < $1.date }
    }

    func history(for deviceId: UUID) -> [StorageHistory] {
        history
            .filter { $0.deviceId == deviceId }
            .sorted { $0.date < $1.date }
    }

    func suggestions(for deviceId: UUID) -> [CleanupSuggestion] {
        suggestions.filter { $0.deviceId == deviceId }
    }

    func addDevice(_ device: StorageDevice) {
        devices.append(device)
        let historyEntry = StorageHistory(
            id: UUID(),
            deviceId: device.id,
            date: device.lastUpdated,
            freeSpace: device.freeSpace
        )
        history.append(historyEntry)
        updateGoals()
    }

    func updateDevice(_ device: StorageDevice, newUsedSpace: Int) {
        guard let index = devices.firstIndex(where: { $0.id == device.id }) else { return }
        let clamped = max(0, min(newUsedSpace, devices[index].totalCapacity))
        devices[index].usedSpace = clamped
        devices[index].lastUpdated = Date()
        let historyEntry = StorageHistory(
            id: UUID(),
            deviceId: device.id,
            date: Date(),
            freeSpace: devices[index].freeSpace
        )
        history.append(historyEntry)
        updateGoals()
        saveToUserDefaults()
    }

    func deleteDevice(_ device: StorageDevice) {
        devices.removeAll { $0.id == device.id }
        history.removeAll { $0.deviceId == device.id }
        analyses.removeAll { $0.deviceId == device.id }
        suggestions.removeAll { $0.deviceId == device.id }
        updateGoals()
    }

    func toggleFavorite(_ device: StorageDevice) {
        guard let index = devices.firstIndex(where: { $0.id == device.id }) else { return }
        devices[index].isFavorite.toggle()
        saveToUserDefaults()
    }

    func addAnalysis(_ analysis: StorageAnalysis) {
        analyses.append(analysis)
        saveToUserDefaults()
    }

    /// Replaces the latest breakdown for a device (one active snapshot per device for the UI).
    func setDeviceAnalysis(_ analysis: StorageAnalysis) {
        analyses.removeAll { $0.deviceId == analysis.deviceId }
        analyses.append(analysis)
        saveToUserDefaults()
    }

    func addSuggestion(_ suggestion: CleanupSuggestion) {
        suggestions.append(suggestion)
        saveToUserDefaults()
    }

    func completeSuggestion(_ suggestion: CleanupSuggestion) {
        guard let index = suggestions.firstIndex(where: { $0.id == suggestion.id }) else { return }
        suggestions[index].isCompleted = true
        if let deviceIndex = devices.firstIndex(where: { $0.id == suggestion.deviceId }) {
            let device = devices[deviceIndex]
            let newFree = min(device.totalCapacity, device.freeSpace + suggestion.potentialFreedSpace)
            let newUsed = device.totalCapacity - newFree
            devices[deviceIndex].usedSpace = newUsed
            devices[deviceIndex].lastUpdated = Date()
            history.append(
                StorageHistory(id: UUID(), deviceId: device.id, date: Date(), freeSpace: newFree)
            )
        }
        updateGoals()
        saveToUserDefaults()
    }

    func addGoal(_ goal: StorageGoal) {
        goals.append(goal)
        saveToUserDefaults()
    }

    func deleteGoal(_ goal: StorageGoal) {
        goals.removeAll { $0.id == goal.id }
        saveToUserDefaults()
    }

    func completeGoal(_ goal: StorageGoal) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index].isCompleted = true
        saveToUserDefaults()
    }

    private func updateGoals() {
        let totalFree = totalFreeSpace
        for i in goals.indices where !goals[i].isCompleted {
            goals[i].currentFreeSpace = totalFree
            if goals[i].currentFreeSpace >= goals[i].targetFreeSpace {
                goals[i].isCompleted = true
            }
        }
        saveToUserDefaults()
    }

    func generateSuggestions(for device: StorageDevice) {
        suggestions.removeAll { $0.deviceId == device.id }
        let free = max(device.freeSpace, 1)
        let newSuggestions: [CleanupSuggestion] = [
            CleanupSuggestion(
                id: UUID(),
                deviceId: device.id,
                title: "Clear downloads",
                description: "Remove old files from your Downloads folder",
                potentialFreedSpace: min(5, max(1, free / 2)),
                category: .downloads,
                isCompleted: false
            ),
            CleanupSuggestion(
                id: UUID(),
                deviceId: device.id,
                title: "Remove duplicate photos",
                description: "Find and delete duplicate photos",
                potentialFreedSpace: min(3, max(1, free / 3)),
                category: .photos,
                isCompleted: false
            ),
            CleanupSuggestion(
                id: UUID(),
                deviceId: device.id,
                title: "Clear app cache",
                description: "Remove temporary app data",
                potentialFreedSpace: min(2, max(1, free / 4)),
                category: .apps,
                isCompleted: false
            )
        ]
        suggestions.append(contentsOf: newSuggestions)
        saveToUserDefaults()
    }

    private let devicesKey = "diskwatch_devices"
    private let analysesKey = "diskwatch_analyses"
    private let suggestionsKey = "diskwatch_suggestions"
    private let goalsKey = "diskwatch_goals"
    private let historyKey = "diskwatch_history"

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(encoded, forKey: devicesKey)
        }
        if let encoded = try? JSONEncoder().encode(analyses) {
            UserDefaults.standard.set(encoded, forKey: analysesKey)
        }
        if let encoded = try? JSONEncoder().encode(suggestions) {
            UserDefaults.standard.set(encoded, forKey: suggestionsKey)
        }
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: devicesKey),
           let decoded = try? JSONDecoder().decode([StorageDevice].self, from: data) {
            devices = decoded
        }
        if let data = UserDefaults.standard.data(forKey: analysesKey),
           let decoded = try? JSONDecoder().decode([StorageAnalysis].self, from: data) {
            analyses = decoded
        }
        if let data = UserDefaults.standard.data(forKey: suggestionsKey),
           let decoded = try? JSONDecoder().decode([CleanupSuggestion].self, from: data) {
            suggestions = decoded
        }
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([StorageGoal].self, from: data) {
            goals = decoded
        }
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([StorageHistory].self, from: data) {
            history = decoded
        }
        if devices.isEmpty {
            loadDemoData()
        } else {
            updateGoals()
        }
    }

    private func loadDemoData() {
        let device1 = StorageDevice(
            id: UUID(),
            name: "iPhone",
            type: .internalStorage,
            totalCapacity: 128,
            usedSpace: 95,
            warningThreshold: 20,
            dangerThreshold: 10,
            lastUpdated: Date(),
            notes: "Primary device",
            isFavorite: true,
            createdAt: Date()
        )
        let device2 = StorageDevice(
            id: UUID(),
            name: "iCloud",
            type: .icloud,
            totalCapacity: 50,
            usedSpace: 42,
            warningThreshold: 20,
            dangerThreshold: 10,
            lastUpdated: Date().addingTimeInterval(-86400),
            notes: "Photos and documents",
            isFavorite: false,
            createdAt: Date()
        )
        devices = [device1, device2]
        let analysis = StorageAnalysis(
            id: UUID(),
            deviceId: device1.id,
            date: Date(),
            categories: [
                .photos: 45,
                .apps: 30,
                .documents: 10,
                .other: 10
            ],
            notes: nil
        )
        analyses = [analysis]
        let totalFree = devices.reduce(0) { $0 + $1.freeSpace }
        let goal = StorageGoal(
            id: UUID(),
            name: "Free up 30 GB",
            targetFreeSpace: 30,
            currentFreeSpace: totalFree,
            deadline: Date().addingTimeInterval(86400 * 30),
            isCompleted: false,
            createdAt: Date()
        )
        goals = [goal]
        history = [
            StorageHistory(id: UUID(), deviceId: device1.id, date: Date().addingTimeInterval(-86400 * 7), freeSpace: 28),
            StorageHistory(id: UUID(), deviceId: device1.id, date: Date().addingTimeInterval(-86400 * 3), freeSpace: 30),
            StorageHistory(id: UUID(), deviceId: device1.id, date: device1.lastUpdated, freeSpace: device1.freeSpace)
        ]
        generateSuggestions(for: device1)
        saveToUserDefaults()
    }
}
