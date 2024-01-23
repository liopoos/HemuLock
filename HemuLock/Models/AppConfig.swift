//
//  AppConfig.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import Foundation
import LaunchAtLogin

struct AppConfig: Codable {
    // Launch At Login state
    var isLaunchAtLogin: Bool = LaunchAtLogin.isEnabled

    // Exec script option
    var isExecScript: Bool = false

    // Whether to enable the do not disturb option
    var isDoNotDisturb: Bool = false

    // Activated event
    var activeEvents: [Int] = [Event.systemLock.tag, Event.systemUnLock.tag]

    // Notify type
    var notifyType: Int = Notify.none.tag

    // Notify config
    var notifyConfig: NotifyConfig = NotifyConfig()

    // Do Not Disturb config
    var doNotDisturbConfig: DoNotDisturbConfig = DoNotDisturbConfig()
}
