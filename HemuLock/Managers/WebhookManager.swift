//
//  WebhookManager.swift
//  HemuLock
//
//  Created by GitHub Copilot on 2026/1/1.
//

import Foundation
import Moya

/**
 WebhookManager handles sending webhook notifications with parallel request support.
 
 This manager sends HTTP POST requests to configured webhook URLs when system events occur.
 It supports:
 - Event filtering (only send for configured events)
 - Parallel async requests (non-blocking)
 - Customizable payload with system information
 */
class WebhookManager {
    static let shared = WebhookManager()
    
    private let provider = MoyaProvider<WebhookAPI>()
    
    // MARK: - Send Webhook
    
    /**
     Send a webhook notification for a system event.
     
     This method:
     - Validates webhook configuration
     - Checks if the event should trigger webhook
     - Constructs payload with event info and optional system details
     - Sends HTTP POST request asynchronously
     
     - Parameters:
       - event: The system event that occurred
       
     - Returns: true if webhook was sent, false if disabled or event not configured
     */
    func send(event: Event) -> Bool {
        let config = appState.appConfig.webhookConfig
        
        // Check if webhook is enabled
        guard config.enabled else {
            print("Webhook disabled, skipping")
            return false
        }
        
        // Check if URL is configured
        guard !config.url.isEmpty,
              let url = URL(string: config.url) else {
            print("Webhook URL invalid or empty")
            return false
        }
        
        // Check if this event should trigger webhook
        guard config.enabledEvents.contains(event.tag) else {
            print("Event \(event.rawValue) not enabled for webhook")
            return false
        }
        
        // Construct payload
        let payload = WebhookPayload(event: event, includeSystemInfo: config.includeSystemInfo)
        
        // Send webhook request
        let api = WebhookAPI.send(url: config.url, payload: payload, timeout: config.timeout)
        
        provider.request(api) { result in
            switch result {
            case .success(let response):
                print("Webhook sent successfully to \(config.url), status: \(response.statusCode)")
            case .failure(let error):
                print("Webhook failed: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    // MARK: - Test Webhook
    
    /**
     Send a test webhook notification to verify configuration.
     
     Used by the UI to test webhook setup before saving.
     
     - Throws: NotifyError.invalidConfig if webhook URL is invalid
     */
    func sendTest() throws {
        let config = appState.appConfig.webhookConfig
        
        guard !config.url.isEmpty,
              let _ = URL(string: config.url) else {
            throw NotifyError.invalidConfig
        }
        
        // Create test payload
        let testPayload = WebhookPayload(
            event: Event.systemLock, // Use a sample event
            includeSystemInfo: config.includeSystemInfo
        )
        
        let api = WebhookAPI.send(url: config.url, payload: testPayload, timeout: config.timeout)
        
        provider.request(api) { result in
            switch result {
            case .success(let response):
                print("Test webhook sent successfully, status: \(response.statusCode)")
                // Show success notification
                SystemNotificationManager.shared.send(
                    title: "WEBHOOK_TEST_SUCCESS_TITLE".localized,
                    message: "WEBHOOK_TEST_SUCCESS_MESSAGE".localized
                )
            case .failure(let error):
                print("Test webhook failed: \(error.localizedDescription)")
                // Show error notification
                SystemNotificationManager.shared.send(
                    title: "WEBHOOK_TEST_FAILED_TITLE".localized,
                    message: error.localizedDescription
                )
            }
        }
    }
}
