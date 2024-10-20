// SleeplessApp.swift
import SwiftUI

@main
struct SleeplessApp: App {
    @StateObject private var settings = Settings()
    @StateObject private var menuBarManager: MenuBarManager
    
    init() {
        let settings = Settings()
        _settings = StateObject(wrappedValue: settings)
        _menuBarManager = StateObject(wrappedValue: MenuBarManager(settings: settings))
    }
    
    var body: some Scene {
        MenuBarExtra {
            EmptyView()
        } label: {
            Image(systemName: menuBarManager.isActive ? "moon.fill" : "moon.zzz")
        }
    }
}
