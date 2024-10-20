// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @State private var newValue: String = ""
    @State private var selectedUnit: TimeOption.TimeUnit = .minutes
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Time Options")
                .font(.title2)
                .fontWeight(.bold)
            
            List {
                ForEach(settings.timeOptions) { option in
                    HStack {
                        Text("\(option.value) \(option.unit.rawValue)")
                        Spacer()
                        Button(action: {
                            settings.timeOptions.removeAll(where: { $0.id == option.id })
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: 200)
            
            HStack {
                TextField("Value", text: $newValue)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                
                Picker("Unit", selection: $selectedUnit) {
                    ForEach(TimeOption.TimeUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .frame(width: 100)
                
                Button("Add") {
                    if let value = Int(newValue), value > 0 {
                        settings.timeOptions.append(TimeOption(value: value, unit: selectedUnit))
                        newValue = ""
                    }
                }
                .disabled(Int(newValue) == nil || Int(newValue)! <= 0)
            }
        }
        .padding()
    }
}
