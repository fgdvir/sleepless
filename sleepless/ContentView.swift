// ContentView.swift
import SwiftUI
import AppKit

struct ContentView: View {
    @State private var selectedDuration: Duration = .oneMinute
    @State private var isActive: Bool = false
    @State private var timeRemaining: TimeInterval = 0
    private let screenSleepManager = ScreenSleepManager()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    enum Duration: String, CaseIterable {
        case oneMinute = "1 Minute"
        case fiveMinutes = "5 Minutes"
        case oneHour = "1 Hour"
        case twoHours = "2 Hours"
        
        var seconds: TimeInterval {
            switch self {
            case .oneMinute: return 60
            case .fiveMinutes: return 300
            case .oneHour: return 3600
            case .twoHours: return 7200
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sleepless")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Prevent your Mac from going to sleep")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Duration", selection: $selectedDuration) {
                ForEach(Duration.allCases, id: \.self) { duration in
                    Text(duration.rawValue).tag(duration)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .disabled(isActive)  // Disable duration selection while active
            
            Button(action: toggleSleepPrevention) {
                Text(isActive ? "Stop" : "Start")
                    .frame(width: 100)
            }
            .buttonStyle(.borderedProminent)
            
            if isActive {
                Text("Screen will stay awake for \(formatTimeRemaining(timeRemaining))")
                    .foregroundColor(.green)
            }
        }
        .frame(width: 400, height: 250)
        .padding()
        .onReceive(timer) { _ in
            if isActive && timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    isActive = false
                }
            }
        }
        .onAppear {
            setupAlwaysOnTop()
        }
    }
    
    private func formatTimeRemaining(_ seconds: TimeInterval) -> String {
        if seconds >= 3600 {
            let hours = Int(seconds) / 3600
            let minutes = Int(seconds) % 3600 / 60
            return "\(hours)h \(minutes)m"
        } else if seconds >= 60 {
            let minutes = Int(seconds) / 60
            let secs = Int(seconds) % 60
            return "\(minutes)m \(secs)s"
        } else {
            return "\(Int(seconds))s"
        }
    }
    
    private func setupAlwaysOnTop() {
        if let window = NSApplication.shared.windows.first {
            window.level = .floating  // Makes window stay on top
        }
    }
    
    private func toggleSleepPrevention() {
        isActive.toggle()
        if isActive {
            timeRemaining = selectedDuration.seconds
            screenSleepManager.preventSleep(for: selectedDuration.seconds)
            print("DEBUG: Sleep prevention started for \(selectedDuration.rawValue)")  // Debug log
        } else {
            timeRemaining = 0
            screenSleepManager.allowSleep()
            print("DEBUG: Sleep prevention stopped")  // Debug log
        }
    }
}
