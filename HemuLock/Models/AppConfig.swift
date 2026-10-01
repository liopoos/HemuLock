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

    // Notify scope: whether to send notifications for system events
    var isNotifyForEvents: Bool = true

    // Notify scope: whether to send notifications when Keep Awake is activated
    var isNotifyForKeepAwake: Bool = true

    // Keep Awake availability and enabled presets
    var isKeepAwakeEnabled: Bool = true
    var enabledKeepAwakeOptions: [Int: Bool] = [:]

    // Do Not Disturb config
    var doNotDisturbConfig: DoNotDisturbConfig = DoNotDisturbConfig()

    /**
     Version 2.0.1 added.
     */
    // Record history record
    var isRecordEvent: Bool = false
    
    /**
     Webhook configuration
     */
    var webhookConfig: WebhookConfig = WebhookConfig()
    
    // MARK: - Custom Decoding
    
    enum CodingKeys: String, CodingKey {
        case isLaunchAtLogin
        case isExecScript
        case isDoNotDisturb
        case activeEvents
        case notifyType
        case notifyConfig
        case isNotifyForEvents
        case isNotifyForKeepAwake
        case isKeepAwakeEnabled
        case enabledKeepAwakeOptions
        case isKeepAwakeTonightEnabled
        case isKeepAwakeMidnightEnabled
        case doNotDisturbConfig
        case isRecordEvent
        case webhookConfig
    }
    
    init() {
        // Default initializer
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode each field with a fallback to default values
        isLaunchAtLogin = (try? container.decode(Bool.self, forKey: .isLaunchAtLogin)) ?? LaunchAtLogin.isEnabled
        isExecScript = (try? container.decode(Bool.self, forKey: .isExecScript)) ?? false
        isDoNotDisturb = (try? container.decode(Bool.self, forKey: .isDoNotDisturb)) ?? false
        activeEvents = (try? container.decode([Int].self, forKey: .activeEvents)) ?? [Event.systemLock.tag, Event.systemUnLock.tag]
        notifyType = (try? container.decode(Int.self, forKey: .notifyType)) ?? Notify.none.tag
        notifyConfig = (try? container.decode(NotifyConfig.self, forKey: .notifyConfig)) ?? NotifyConfig()
        isNotifyForEvents = (try? container.decode(Bool.self, forKey: .isNotifyForEvents)) ?? true
        isNotifyForKeepAwake = (try? container.decode(Bool.self, forKey: .isNotifyForKeepAwake)) ?? true
        isKeepAwakeEnabled = (try? container.decode(Bool.self, forKey: .isKeepAwakeEnabled)) ?? true
        enabledKeepAwakeOptions = (try? container.decode([Int: Bool].self, forKey: .enabledKeepAwakeOptions)) ?? [:]
        if let legacyTonight = try? container.decode(Bool.self, forKey: .isKeepAwakeTonightEnabled) {
            enabledKeepAwakeOptions[KeepAwakePreset.tonight.rawValue] = legacyTonight
        }
        if let legacyMidnight = try? container.decode(Bool.self, forKey: .isKeepAwakeMidnightEnabled) {
            enabledKeepAwakeOptions[KeepAwakePreset.midnight.rawValue] = legacyMidnight
        }
        doNotDisturbConfig = (try? container.decode(DoNotDisturbConfig.self, forKey: .doNotDisturbConfig)) ?? DoNotDisturbConfig()
        isRecordEvent = (try? container.decode(Bool.self, forKey: .isRecordEvent)) ?? false
        webhookConfig = (try? container.decode(WebhookConfig.self, forKey: .webhookConfig)) ?? WebhookConfig()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isLaunchAtLogin, forKey: .isLaunchAtLogin)
        try container.encode(isExecScript, forKey: .isExecScript)
        try container.encode(isDoNotDisturb, forKey: .isDoNotDisturb)
        try container.encode(activeEvents, forKey: .activeEvents)
        try container.encode(notifyType, forKey: .notifyType)
        try container.encode(notifyConfig, forKey: .notifyConfig)
        try container.encode(isNotifyForEvents, forKey: .isNotifyForEvents)
        try container.encode(isNotifyForKeepAwake, forKey: .isNotifyForKeepAwake)
        try container.encode(isKeepAwakeEnabled, forKey: .isKeepAwakeEnabled)
        try container.encode(enabledKeepAwakeOptions, forKey: .enabledKeepAwakeOptions)
        try container.encode(doNotDisturbConfig, forKey: .doNotDisturbConfig)
        try container.encode(isRecordEvent, forKey: .isRecordEvent)
        try container.encode(webhookConfig, forKey: .webhookConfig)
    }
}
