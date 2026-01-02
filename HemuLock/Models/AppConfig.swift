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
        doNotDisturbConfig = (try? container.decode(DoNotDisturbConfig.self, forKey: .doNotDisturbConfig)) ?? DoNotDisturbConfig()
        isRecordEvent = (try? container.decode(Bool.self, forKey: .isRecordEvent)) ?? false
        webhookConfig = (try? container.decode(WebhookConfig.self, forKey: .webhookConfig)) ?? WebhookConfig()
    }
}
