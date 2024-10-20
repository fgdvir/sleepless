// ScreenSleepManager.swift
import Foundation
import IOKit.pwr_mgt

class ScreenSleepManager {
    private var assertionID: IOPMAssertionID = 0
    private var timer: Timer?
    
    func preventSleep(for duration: TimeInterval) {
        createAssertion()
        
        // Cancel any existing timer
        timer?.invalidate()
        
        // Schedule sleep re-enable
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.allowSleep()
        }
    }
    
    func preventSleepForever() {
        createAssertion()
        timer?.invalidate()
        timer = nil
    }
    
    private func createAssertion() {
        var assertionID: IOPMAssertionID = 0
        let reason = "User requested sleep prevention" as CFString
        let success = IOPMAssertionCreateWithDescription(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            reason,
            nil,
            nil,
            nil,
            0,
            nil,
            &assertionID)
        
        if success == kIOReturnSuccess {
            self.assertionID = assertionID
        }
    }
    
    func allowSleep() {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
            timer?.invalidate()
            timer = nil
        }
    }
    
    deinit {
        allowSleep()
    }
}
