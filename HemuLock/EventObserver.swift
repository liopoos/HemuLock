//
//  EventObserver.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import Cocoa
import Foundation

class EventObserver {
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

        if !appState.appConfig.activeEvents.contains(event.tag) {
            return
        }

        // Handle record event to db.
        recordEvent(event: event)

        // Send notify.
        if appState.appConfig.notifyType != Notify.none.tag {
            sendNotify(event: event)
        }

        // Exec some local script.
        if appState.appConfig.isExecScript {
            runScript("123")
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
        if event != nil && appState.appConfig.doNotDisturbConfig.type.notify && DisturbModeManager.shared.inDisturb() { return }

        var title = "NOTIFY_MESSAGE_TITLE".localized
        if let deviceName = Host.current().localizedName {
            title = deviceName + "NOTIFY_MESSAGE_TITLE_DEVICE".localized
        }
        let message = event != nil ? event!.name : "NOTIFY_TEST_MESSAGE"

        do {
            try _ = NotifyManager.shared.send(title: title, message: message.localized)
        } catch {
            switch error {
            case NotifyError.invalidConfig:
                sendSystemNotify(title: title, message: NotifyError.invalidConfig.message.localized)
            default:
                sendSystemNotify(title: title, message: "UNHANDLED_ERROR".localized)
            }
        }
    }

    /**
     Send system notify.
     */
    func sendSystemNotify(title: String, message: String) {
        let notify = NSUserNotification()
        notify.title = title
        notify.informativeText = message
        notify.deliveryDate = Date().addingTimeInterval(1)
        NSUserNotificationCenter.default.scheduleNotification(notify)
    }

    /**
     Run shell script/
     */
    func runScript(_ params: String) {
        if appState.appConfig.doNotDisturbConfig.type.script && DisturbModeManager.shared.inDisturb() { return }

        guard let directory = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return }
        let file = directory.appendingPathComponent("script")
        let process = Process()
        process.executableURL = file
        process.arguments = [params]
        try? process.run()
    }
}
