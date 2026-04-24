//
//  WebhookAPI.swift
//  HemuLock
//
//  Created by GitHub Copilot on 2026/1/1.
//

import Foundation
import Moya

enum WebhookAPI {
    case send(url: String, payload: WebhookPayload, timeout: TimeInterval)
}

extension WebhookAPI: TargetType {
    var baseURL: URL {
        switch self {
        case let .send(urlString, _, _):
            // Parse URL and extract base URL
            if let url = URL(string: urlString) {
                return url
            }
            // Fallback to placeholder if URL is invalid
            return URL(string: "https://invalid.webhook.url")!
        }
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        switch self {
        case let .send(_, payload, _):
            return .requestJSONEncodable(payload)
        }
    }
    
    var headers: [String: String]? {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        return [
            "Content-Type": "application/json",
            "User-Agent": "HemuLock/\(version)",
            "X-HemuLock-Version": version
        ]
    }
}
