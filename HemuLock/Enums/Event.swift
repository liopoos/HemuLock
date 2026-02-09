//
//  Event.swift
//  hemu
//
//  Created by hades on 2021/4/1.
//

import AppKit
import Foundation

enum Event: String, CaseIterable {
    case screenSeeep = "SCREEN_SLEEP"
    case screenWake = "SCREEN_WAKE"
    case systemSleep = "SYSTEM_SLEEP"
    case systemWake = "SYSTEM_WAKE"
    case systemLock = "SYSTEM_LOCK"
    case systemUnLock = "SYSTEM_UNLOCK"
    case systemLaunch = "SYSTEM_LAUNCH"

    var name: String {
        return rawValue
    }

    var tag: Int {
        switch self {
        case .screenSeeep:
            return 110
        case .screenWake:
            return 111
        case .systemSleep:
            return 120
        case .systemWake:
            return 121
        case .systemLock:
            return 130
        case .systemUnLock:
            return 131
        case .systemLaunch:
            return 140
        }
    }

    var notification: Notification.Name {
        switch self {
        case .screenSeeep:
            return NSWorkspace.screensDidSleepNotification
        case .screenWake:
            return NSWorkspace.screensDidWakeNotification
        case .systemSleep:
            return NSWorkspace.willSleepNotification
        case .systemWake:
            return NSWorkspace.didWakeNotification
        case .systemLock:
            return NSNotification.Name(rawValue: "com.apple.screenIsLocked")
        case .systemUnLock:
            return NSNotification.Name(rawValue: "com.apple.screenIsUnlocked")
        case .systemLaunch:
            // This event is triggered manually, not via system notification
            return NSNotification.Name(rawValue: "com.hemulock.systemLaunch")
        }
    }
}
