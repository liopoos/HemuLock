//
//  NotiftManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import Foundation
import Moya

/**
 NotifyManager handles sending notifications to external services.
 
 This manager integrates with multiple notification services (Pushover, Bark)
 using the Moya networking library. It validates service configurations and sends
 notifications based on the user's selected notification type.
 */
class NotifyManager {
    static let shared = NotifyManager()

    private let provider = MoyaProvider<NotifyAPI>()

    // MARK: - Send Notification
    
    /**
     Send a notification to the configured external service.
     
     This method:
     - Validates the service configuration
     - Selects the appropriate API based on notification type
     - Sends the notification asynchronously
     
     - Parameters:
       - title: The title of the notification
       - message: The body content of the notification
       
     - Throws: NotifyError.invalidConfig if required configuration is missing
     - Returns: true if the notification was sent successfully, false if no valid service is configured
     */
    func send(title: String, message: String) throws -> Bool {
        let config = appState.appConfig.notifyConfig
        let api: NotifyAPI

        switch appState.appConfig.notifyType {
        case Notify.pushover.tag:
            if config.pushover.token.isEmpty || config.pushover.user.isEmpty {
                throw NotifyError.invalidConfig
            }
            api = .pushover(user: config.pushover.user, token: config.pushover.token, device: config.pushover.device, title: title, message: message)
        case Notify.bark.tag:
            if config.bark.server.isEmpty || config.bark.device.isEmpty {
                throw NotifyError.invalidConfig
            }
            api = .bark(server: config.bark.server, device: config.bark.device, title: title, message: message, level: config.bark.critical ? "critical" : "")
        default:
            return false
        }

        // Send notify.
        provider.request(api) { result in
            switch result {
            case .success:
                print("send notify success")
            case let .failure(error):
                print("send notify failed: \(error)")
            }
        }

        return true
    }
}
