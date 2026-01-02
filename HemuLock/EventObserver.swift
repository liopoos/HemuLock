//
//  EventObserver.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import Cocoa
import Foundation
import UserNotifications
import Logging

class EventObserver {
    private let logger = LogManager.shared.logger(for: "EventObserver")
    
    init() {
        // Screen sleep
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handleEvent(_:)), name: Event.screenSeeep.notification, object: nil)
        // Screen wake
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handleEvent(_:)), name: Event.screenWake.notification, object: nil)
        // System sleep
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handleEvent(_:)), name: Event.systemSleep.notification, object: nil)
        // System wake
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handleEvent(_:)), name: Event.systemWake.notification, object: nil)
        // System lock
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(handleEvent(_:)), name: Event.systemLock.notification, object: nil)
        // System unlock
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(handleEvent(_:)), name: Event.systemUnLock.notification, object: nil)
    }

    /**
     Handle event.
     */
    @objc func handleEvent(_ notification: Notification) {
        guard let event = Event.allCases.first(where: { e in
            e.notification == notification.name
        }) else {
            return
        }
        
        // Log event trigger
        logger.info("Event triggered: \(event.name)")
        
        // Handle record event to db.
        if appState.appConfig.isRecordEvent {
            recordEvent(event: event)
        }
        
        if !appState.appConfig.activeEvents.contains(event.tag) {
            logger.debug("Event \(event.name) is not active, skipping")
            return
        }

        // Send notify.
        if appState.appConfig.notifyType != Notify.none.tag {
            sendNotify(event: event)
        }
        
        // Send webhook if configured
        if appState.appConfig.webhookConfig.enabled {
            sendWebhook(event: event)
        }

        // Exec some local script.
        if appState.appConfig.isExecScript {
            runScript(event.name)
        }
    }

    /**
     Record event log to db.
     */
    func recordEvent(event: Event) {
        let record = Record(event: event.rawValue, isNotify: true)
        _ = RecordRepository.shared.insertRecord(record: record)
    }

    /**
     Send sevice notify.
     */
    func sendNotify(event: Event? = nil) {
        if event != nil && appState.appConfig.doNotDisturbConfig.type.notify && DisturbModeManager.shared.inDisturb() {
            logger.debug("Notify skipped for event \(event!.name): In Do Not Disturb mode")
            return
        }

        var title = "NOTIFY_MESSAGE_TITLE".localized
        if let deviceName = Host.current().localizedName {
            title = deviceName + "NOTIFY_MESSAGE_TITLE_DEVICE".localized
        }
        let message = event != nil ? event!.name : "NOTIFY_TEST_MESSAGE"

        do {
            try _ = NotifyManager.shared.send(title: title, message: message.localized)
            if let event = event {
                logger.info("Notify sent successfully for event: \(event.name)")
            } else {
                logger.info("Test notify sent successfully")
            }
        } catch {
            switch error {
            case NotifyError.invalidConfig:
                logger.error("Notify failed: Invalid config for event \(event?.name ?? "test")")
                sendSystemNotify(title: title, message: NotifyError.invalidConfig.message.localized)
            default:
                logger.error("Notify failed: Unhandled error for event \(event?.name ?? "test")")
                sendSystemNotify(title: title, message: "UNHANDLED_ERROR".localized)
            }
        }
    }

    /**
     Send system notify.
     */
    func sendSystemNotify(title: String, message: String) {
        SystemNotificationManager.shared.sendDelayed(title: title, message: message, delay: 1)
    }

    /**
     Send webhook notification.
     */
    func sendWebhook(event: Event) {
        if appState.appConfig.doNotDisturbConfig.type.notify && DisturbModeManager.shared.inDisturb() {
            logger.debug("Webhook skipped for event \(event.name): In Do Not Disturb mode")
            return
        }
        let result = WebhookManager.shared.send(event: event)
        if result {
            logger.info("Webhook sent successfully for event: \(event.name)")
        } else {
            logger.debug("Webhook skipped for event \(event.name)")
        }
    }

    /**
     Run shell script/
     */
    func runScript(_ params: String) {
        if appState.appConfig.doNotDisturbConfig.type.script && DisturbModeManager.shared.inDisturb() {
            logger.debug("Script execution skipped for event \(params): In Do Not Disturb mode")
            return
        }
        let file = ScriptManager.shared.getFile()
        let process = Process()
        process.executableURL = file
        process.arguments = [params]
        do {
            try process.run()
            logger.info("Script executed successfully for event: \(params)")
        } catch {
            logger.error("Script execution failed for event \(params): \(error.localizedDescription)")
        }
    }
}
