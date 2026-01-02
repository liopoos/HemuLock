//
//  LogManager.swift
//  HemuLock
//
//  Created by GitHub Copilot on 2026/1/2.
//

import Foundation
import Logging

/// Manages the application's logging system with file rotation and cleanup.
class LogManager {
    // MARK: - Singleton
    
    static let shared = LogManager()
    
    // MARK: - Properties
    
    private let logsDirectory: URL
    private let fileManager = FileManager.default
    
    // MARK: - Initialization
    
    private init() {
        // Get application support directory
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access Application Support directory")
        }
        
        // Create logs directory path
        logsDirectory = AppInfoHelper.shared.logsDirectory
        
        // Initialize logging system
        bootstrapLogging()
        
        // Clean old logs on startup
        cleanOldLogs()
    }
    
    // MARK: - Logger Factory
    
    /// Creates a logger instance for the specified component.
    /// - Parameter label: The component identifier (e.g., "AppDelegate", "ScriptManager")
    /// - Returns: A configured Logger instance
    func logger(for label: String) -> Logger {
        return Logger(label: "\(AppInfoHelper.shared.bundleIdentifier).\(label)")
    }
    
    // MARK: - Public Methods
    
    /// Returns the URL of the logs directory.
    func getLogsDirectory() -> URL {
        return logsDirectory
    }
    
    /// Cleans up log files older than the specified number of days.
    /// - Parameter keepDays: Number of days to keep logs (default: 7)
    func cleanOldLogs(keepDays: Int = 7) {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: logsDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return
        }
        
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -keepDays, to: Date()) ?? Date()
        
        for fileURL in contents {
            guard fileURL.pathExtension == "log" else { continue }
            
            if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
               let creationDate = attributes[.creationDate] as? Date,
               creationDate < cutoffDate {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func bootstrapLogging() {
        #if DEBUG
        // In debug mode, log to both console and file
        LoggingSystem.bootstrap { label in
            do {
                return MultiplexLogHandler([
                    try FileLogHandler(label: label, logDirectory: self.logsDirectory),
                    StreamLogHandler.standardOutput(label: label)
                ])
            } catch {
                // Fallback to console only if file logging fails
                print("Failed to initialize FileLogHandler: \(error)")
                return StreamLogHandler.standardOutput(label: label)
            }
        }
        #else
        // In release mode, only log to file
        LoggingSystem.bootstrap { label in
            do {
                return try FileLogHandler(label: label, logDirectory: self.logsDirectory)
            } catch {
                // Fallback to console if file logging fails
                print("Failed to initialize FileLogHandler: \(error)")
                return StreamLogHandler.standardOutput(label: label)
            }
        }
        #endif
    }
}

/// A log handler that multiplexes log messages to multiple handlers.
struct MultiplexLogHandler: LogHandler {
    private var handlers: [LogHandler]
    
    var logLevel: Logger.Level {
        get {
            return handlers.first?.logLevel ?? .info
        }
        set {
            for i in handlers.indices {
                handlers[i].logLevel = newValue
            }
        }
    }
    
    var metadata: Logger.Metadata {
        get {
            return handlers.first?.metadata ?? [:]
        }
        set {
            for i in handlers.indices {
                handlers[i].metadata = newValue
            }
        }
    }
    
    init(_ handlers: [LogHandler]) {
        self.handlers = handlers
    }
    
    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return handlers.first?[metadataKey: key]
        }
        set {
            for i in handlers.indices {
                handlers[i][metadataKey: key] = newValue
            }
        }
    }
    
    func log(level: Logger.Level,message: Logger.Message,metadata: Logger.Metadata?,source: String,file: String,function: String,line: UInt) {
        for handler in handlers {
            handler.log(level: level,message: message,metadata: metadata,source: source,file: file,function: function,line: line)
        }
    }
}
