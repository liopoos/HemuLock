//
//  SystemNotificationManager.swift
//  HemuLock
//
//  Created by hades on 2025/12/28.
//

import Foundation
import UserNotifications
import Logging

/**
 SystemNotificationManager manages all system notification related operations,
 including authorization requests and sending notifications.
 
 This manager provides a unified interface for sending notifications throughout the app,
 ensuring consistent behavior and proper error handling.
 */
class SystemNotificationManager: NSObject {
    static let shared = SystemNotificationManager()
    private let logger = LogManager.shared.logger(for: "SystemNotificationManager")
    
    private override init() {
        super.init()
    }
    
    // MARK: - Authorization
    
    /**
     Request notification authorization from the user.
     Should be called during app launch.
     
     - Parameter completion: Optional completion handler with authorization result
     */
    func requestAuthorization(completion: ((Bool, Error?) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                self.logger.error("Notification authorization failed: \(error.localizedDescription)")
            } else if granted {
                self.logger.info("Notification authorization granted")
            } else {
                self.logger.info("Notification authorization denied")
            }
            
            completion?(granted, error)
        }
    }
    
    /**
     Set the notification center delegate.
     Should be called during app launch.
     
     - Parameter delegate: The delegate to handle notification center callbacks
     */
    func setDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter.current().delegate = delegate
    }
    
    // MARK: - Send Notifications
    
    /**
     Send an immediate notification.
     
     - Parameters:
       - title: The title of the notification
       - message: The body content of the notification
       - sound: Whether to play sound (default: true)
       - completion: Optional completion handler
     */
    func send(title: String, message: String, sound: Bool = true, completion: ((Error?) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        if sound {
            content.sound = .default
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Send notification failed: \(error.localizedDescription)")
            }
            completion?(error)
        }
    }
    
    /**
     Send a delayed notification.
     
     - Parameters:
       - title: The title of the notification
       - message: The body content of the notification
       - delay: The delay in seconds before showing the notification
       - sound: Whether to play sound (default: true)
       - completion: Optional completion handler
     */
    func sendDelayed(title: String, message: String, delay: TimeInterval, sound: Bool = true, completion: ((Error?) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        if sound {
            content.sound = .default
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Send delayed notification failed: \(error.localizedDescription)")
            }
            completion?(error)
        }
    }
    
    /**
     Remove all pending notifications.
     */
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /**
     Remove all delivered notifications from notification center.
     */
    func removeAllDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
