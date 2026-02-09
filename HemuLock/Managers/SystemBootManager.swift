//
//  SystemBootManager.swift
//  HemuLock
//
//  Created by HemuLock on 2024/02/09.
//

import Foundation

/**
 SystemBootManager handles detection of system boot events.
 
 This manager tracks system boot time and determines if a notification
 for the current boot has already been sent. It uses sysctl to get the
 system boot time and UserDefaults to persist the last notified boot time.
 */
class SystemBootManager {
    static let shared = SystemBootManager()
    
    private let lastBootTimeKey = "last_notified_boot_time"
    
    // Tolerance in seconds for comparing boot times.
    // System boot times may have minor differences due to precision,
    // so we use a 1-second tolerance to avoid false positives.
    private let bootTimeToleranceSeconds: TimeInterval = 1.0
    
    private init() {}
    
    /**
     Get the current system boot time using sysctl.
     
     - Returns: The date when the system was last booted, or nil if unable to determine
     */
    func getSystemBootTime() -> Date? {
        var mib = [CTL_KERN, KERN_BOOTTIME]
        var bootTime = timeval()
        var size = MemoryLayout<timeval>.stride
        
        if sysctl(&mib, UInt32(mib.count), &bootTime, &size, nil, 0) != -1 {
            return Date(timeIntervalSince1970: TimeInterval(bootTime.tv_sec))
        }
        return nil
    }
    
    /**
     Check if this is a new system boot (not just app relaunch).
     
     Compares the current system boot time with the last boot time that was notified.
     
     - Returns: true if this is a new boot that hasn't been notified yet, false otherwise
     */
    func isNewSystemBoot() -> Bool {
        guard let currentBootTime = getSystemBootTime() else {
            // If we can't determine boot time, don't trigger the event
            return false
        }
        
        // Get the last notified boot time from UserDefaults
        if let lastBootTime = UserDefaults.standard.object(forKey: lastBootTimeKey) as? Date {
            // If the boot times are different, it's a new boot
            // Allow a small tolerance for timing differences
            return abs(currentBootTime.timeIntervalSince(lastBootTime)) > bootTimeToleranceSeconds
        }
        
        // If no previous boot time is stored, consider it a new boot
        return true
    }
    
    /**
     Mark the current boot as notified.
     
     Stores the current system boot time in UserDefaults to prevent
     duplicate notifications for the same boot.
     */
    func markBootNotified() {
        guard let currentBootTime = getSystemBootTime() else {
            return
        }
        UserDefaults.standard.set(currentBootTime, forKey: lastBootTimeKey)
    }
}
