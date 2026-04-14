//
//  WebhookConfig.swift
//  HemuLock
//
//  Created by GitHub Copilot on 2026/1/1.
//

import Foundation

struct WebhookConfig: Codable {
    /// Webhook URL
    var url: String = ""
    
    /// Enable webhook
    var enabled: Bool = false
    
    /// Events that will trigger webhook (stored as event tags)
    var enabledEvents: [Int] = []
    
    /// HTTP timeout in seconds
    var timeout: TimeInterval = 10.0
    
    /// Include system info in payload
    var includeSystemInfo: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case url, enabled, enabledEvents, timeout, includeSystemInfo
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = (try? container.decode(String.self, forKey: .url)) ?? ""
        enabled = (try? container.decode(Bool.self, forKey: .enabled)) ?? false
        enabledEvents = (try? container.decode([Int].self, forKey: .enabledEvents)) ?? []
        timeout = (try? container.decode(TimeInterval.self, forKey: .timeout)) ?? 10.0
        includeSystemInfo = (try? container.decode(Bool.self, forKey: .includeSystemInfo)) ?? true
    }
}

// MARK: - Webhook Payload Structure
struct WebhookPayload: Codable {
    let event: String
    let timestamp: String
    let device: DeviceInfo?
    
    struct DeviceInfo: Codable {
        let hostname: String
        let username: String
        let osVersion: String
        
        static func current() -> DeviceInfo {
            let processInfo = ProcessInfo.processInfo
            return DeviceInfo(
                hostname: processInfo.hostName,
                username: NSUserName(),
                osVersion: processInfo.operatingSystemVersionString
            )
        }
    }
    
    init(event: Event, includeSystemInfo: Bool) {
        self.event = event.rawValue
        
        let formatter = ISO8601DateFormatter()
        self.timestamp = formatter.string(from: Date())
        
        self.device = includeSystemInfo ? DeviceInfo.current() : nil
    }
}
