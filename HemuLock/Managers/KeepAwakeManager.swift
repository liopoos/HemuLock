//
//  KeepAwakeManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/22.
//

import Combine
import Foundation
import Logging

class KeepAwakeManager: ObservableObject {
    static let shared = KeepAwakeManager()
    private let logger = LogManager.shared.logger(for: "KeepAwakeManager")

    @Published private var process: Process?
    @Published private(set) var activeDuration: KeepAwakeDuration?
    @Published private(set) var activePreset: KeepAwakePreset?
    @Published private(set) var endDate: Date?
    private var deadlineTimer: Timer?

    private init() {}

    var isActive: Bool {
        return process?.isRunning == true
    }

    var currentPID: Int? {
        guard let p = process, p.isRunning else { return nil }
        return Int(p.processIdentifier)
    }

    var remainingSeconds: Int? {
        guard isActive else { return nil }
        guard let end = endDate else { return nil }
        return max(0, Int(ceil(end.timeIntervalSinceNow)))
    }

    var countdownText: String {
        guard let seconds = remainingSeconds else { return "KEEP_AWAKE_PERMANENT".localized }
        return String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }

    func untilTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return String(format: "KEEP_AWAKE_END_AT_FORMAT".localized, formatter.string(from: date))
    }

    func start(duration: KeepAwakeDuration) {
        let deadline = duration.seconds.map { Date().addingTimeInterval(TimeInterval($0)) }
        let message = duration == .permanent
            ? "KEEP_AWAKE_NOTIFY_PERMANENT".localized
            : String(format: "KEEP_AWAKE_NOTIFY_TIMED".localized, duration.localizationKey.localized)
        start(duration: duration, until: deadline, notification: message)
    }

    func start(until preset: KeepAwakePreset) {
        let deadline = preset.deadline()
        guard deadline > Date() else { return }
        start(duration: nil, preset: preset, until: deadline, notification: preset.localizationKey.localized)
    }

    private func start(duration: KeepAwakeDuration?, preset: KeepAwakePreset? = nil, until deadline: Date?, notification: String) {
        guard appState.appConfig.isKeepAwakeEnabled else { return }
        if let deadline, deadline <= Date() { return }
        stop()

        // Bind every child to the app lifetime so it cannot remain after the app exits.
        var arguments = ["-i", "-d", "-w", "\(ProcessInfo.processInfo.processIdentifier)"]
        if let deadline {
            let seconds = max(1, Int(ceil(deadline.timeIntervalSinceNow)))
            arguments += ["-t", "\(seconds)"]
        }

        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        p.arguments = arguments
        p.terminationHandler = { [weak self] finishedProcess in
            DispatchQueue.main.async {
                guard let self, self.process === finishedProcess else { return }
                self.stop()
            }
        }

        do {
            try p.run()
            process = p
            activeDuration = duration
            activePreset = preset
            endDate = deadline
            if let deadline {
                let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
                    if Date() >= deadline { self?.stop() }
                }
                deadlineTimer = timer
                RunLoop.main.add(timer, forMode: .common)
            }
            logger.info("caffeinate started: pid=\(p.processIdentifier)")
            sendNotify(message: notification)
        } catch {
            logger.error("Failed to start caffeinate: \(error)")
        }
    }

    private func sendNotify(message: String) {
        guard appState.appConfig.notifyType != Notify.none.tag && appState.appConfig.isNotifyForKeepAwake else { return }

        var title = "NOTIFY_MESSAGE_TITLE".localized
        if let deviceName = Host.current().localizedName {
            title = deviceName + "NOTIFY_MESSAGE_TITLE_DEVICE".localized
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
        deadlineTimer?.invalidate()
        deadlineTimer = nil
        if let p = process, p.isRunning {
            let pid = p.processIdentifier
            p.terminate()
            p.waitUntilExit()
            logger.info("caffeinate stopped: pid=\(pid)")
        }
        process = nil
        activeDuration = nil
        activePreset = nil
        endDate = nil
    }
}
