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
    case appBoot = "APP_BOOT"
    case systemShutdown = "SYSTEM_SHUTDOWN"
    case systemSleep = "SYSTEM_SLEEP"
    case systemWake = "SYSTEM_WAKE"
    case systemLock = "SYSTEM_LOCK"
    case systemUnLock = "SYSTEM_UNLOCK"

    var name: String {
        return rawValue
    }

    var tag: Int {
        switch self {
        case .appBoot:
            return 100
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
        case .systemShutdown:
            return 141
        }
    }

    var notification: Notification.Name {
        switch self {
        case .appBoot:
            return Notification.Name("HemuLock.app.boot")
        case .systemShutdown:
            return NSWorkspace.willPowerOffNotification
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
        }
    }
}
