// MenuBarManager.swift
import SwiftUI
import AppKit

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    @ObservedObject var settings: Settings
    private let screenSleepManager = ScreenSleepManager()
    @Published var isActive = false
    @Published var selectedOption: TimeOption?
    @Published var isForever = false
    
    init(settings: Settings) {
        self.settings = settings
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.target = self
            button.action = #selector(handleClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Create and set the menu
        statusItem?.menu = createMenu()
        updateMenuBarIcon()
    }
    
    @objc private func handleClick() {
        let event = NSApp.currentEvent!
        
        if event.type == .leftMouseUp {
            toggleCurrentState()
        }
        // Right clicks will automatically show the menu since it's set on the statusItem
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Forever option
        let foreverItem = NSMenuItem(title: "Awake Forever", action: #selector(toggleForever), keyEquivalent: "")
        foreverItem.target = self
        foreverItem.state = isForever ? .on : .off
        menu.addItem(foreverItem)
        
        menu.addItem(.separator())
        
        // Time options
        for option in settings.timeOptions {
            let item = NSMenuItem(
                title: option.displayString,
                action: #selector(selectTimeOption(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = option
            item.state = (selectedOption == option && !isForever) ? .on : .off
            menu.addItem(item)
        }
        
        menu.addItem(.separator())
        
        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // Quit option
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        return menu
    }
    
    @objc private func selectTimeOption(_ sender: NSMenuItem) {
        guard let option = sender.representedObject as? TimeOption else { return }
        selectedOption = option
        isForever = false
        startTimer(duration: option.seconds)
        statusItem?.menu = createMenu() // Refresh menu to update checkmarks
    }
    
    @objc private func toggleForever() {
        isForever.toggle()
        if isForever {
            selectedOption = nil
            startForever()
        } else {
            stopTimer()
        }
        statusItem?.menu = createMenu() // Refresh menu to update checkmarks
    }
    
    private func toggleCurrentState() {
        if isActive {
            stopTimer()
        } else if let option = selectedOption {
            startTimer(duration: option.seconds)
        } else if isForever {
            startForever()
        }
        statusItem?.menu = createMenu() // Refresh menu to update state
    }
    
    private func startTimer(duration: TimeInterval) {
        isActive = true
        updateMenuBarIcon()
        screenSleepManager.preventSleep(for: duration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.isActive = false
            self?.updateMenuBarIcon()
            self?.statusItem?.menu = self?.createMenu() // Refresh menu after timer completes
        }
    }
    
    private func startForever() {
        isActive = true
        updateMenuBarIcon()
        screenSleepManager.preventSleepForever()
    }
    
    private func stopTimer() {
        isActive = false
        updateMenuBarIcon()
        screenSleepManager.allowSleep()
    }
    
    private func updateMenuBarIcon() {
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: isActive ? "moon.fill" : "moon.zzz", accessibilityDescription: "Sleepless")
        }
    }
    
    @objc private func openSettings() {
        if popover == nil {
            let popover = NSPopover()
            popover.contentSize = NSSize(width: 300, height: 400)
            popover.behavior = .transient
            popover.contentViewController = NSHostingController(
                rootView: SettingsView(settings: settings)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            )
            self.popover = popover
        }
        
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
