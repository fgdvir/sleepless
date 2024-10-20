// Settings.swift
import Foundation

class Settings: ObservableObject {
    @Published var timeOptions: [TimeOption] = [] {
        didSet {
            saveTimeOptions()
        }
    }
    
    private let defaults = UserDefaults.standard
    private let timeOptionsKey = "timeOptions"
    
    init() {
        loadTimeOptions()
        if timeOptions.isEmpty {
            // Default options
            timeOptions = [
                TimeOption(value: 1, unit: .minutes),
                TimeOption(value: 5, unit: .minutes),
                TimeOption(value: 1, unit: .hours),
                TimeOption(value: 2, unit: .hours)
            ]
        }
    }
    
    private func loadTimeOptions() {
        if let data = defaults.data(forKey: timeOptionsKey),
           let decoded = try? JSONDecoder().decode([TimeOption].self, from: data) {
            timeOptions = decoded
        }
    }
    
    private func saveTimeOptions() {
        if let encoded = try? JSONEncoder().encode(timeOptions) {
            defaults.set(encoded, forKey: timeOptionsKey)
        }
    }
}
