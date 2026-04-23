//
//  KeepAwakeManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/22.
//

import Foundation
import Logging

class KeepAwakeManager {
    static let shared = KeepAwakeManager()
    private let logger = LogManager.shared.logger(for: "KeepAwakeManager")

    private var process: Process?
    private(set) var activeDuration: KeepAwakeDuration?

    private init() {}

    var isActive: Bool {
        return process?.isRunning == true
    }

    func start(duration: KeepAwakeDuration) {
        stop()

        var arguments = ["-i", "-d"]
        if let seconds = duration.seconds {
            arguments += ["-t", "\(seconds)"]
        }

        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        p.arguments = arguments
        p.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                if self?.activeDuration == duration {
                    self?.activeDuration = nil
                }
                self?.process = nil
            }
        }

        do {
            try p.run()
            process = p
            activeDuration = duration
            logger.info("caffeinate started: pid=\(p.processIdentifier) duration=\(duration)")
            sendNotify(duration: duration)
        } catch {
            logger.error("Failed to start caffeinate: \(error)")
        }
    }

    private func sendNotify(duration: KeepAwakeDuration) {
        guard appState.appConfig.notifyType != Notify.none.tag && appState.appConfig.isNotifyForKeepAwake else { return }

        var title = "NOTIFY_MESSAGE_TITLE".localized
        if let deviceName = Host.current().localizedName {
            title = deviceName + "NOTIFY_MESSAGE_TITLE_DEVICE".localized
        }

        let message: String
        if duration == .permanent {
            message = "KEEP_AWAKE_NOTIFY_PERMANENT".localized
        } else {
            message = String(format: "KEEP_AWAKE_NOTIFY_TIMED".localized, duration.localizationKey.localized)
        }

        do {
            try _ = NotifyManager.shared.send(title: title, message: message)
        } catch NotifyError.invalidConfig {
            logger.error("Keep awake notify failed: invalid config")
        } catch {
            logger.error("Keep awake notify failed: \(error)")
        }
    }

    func stop() {
        guard let p = process, p.isRunning else {
            process = nil
            activeDuration = nil
            return
        }
        let pid = p.processIdentifier
        p.terminate()
        process = nil
        activeDuration = nil
        logger.info("caffeinate stopped: pid=\(pid)")
    }
}
