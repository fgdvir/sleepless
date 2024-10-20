// TimeOption.swift
import Foundation

struct TimeOption: Identifiable, Codable, Equatable {
    var id = UUID()
    var value: Int
    var unit: TimeUnit
    
    enum TimeUnit: String, Codable, CaseIterable {
        case minutes = "Minutes"
        case hours = "Hours"
        
        var shortForm: String {
            switch self {
            case .minutes: return "m"
            case .hours: return "h"
            }
        }
    }
    
    var seconds: TimeInterval {
        switch unit {
        case .minutes: return TimeInterval(value * 60)
        case .hours: return TimeInterval(value * 3600)
        }
    }
    
    var displayString: String {
        "\(value)\(unit.shortForm)"
    }
}
