//
//  FileLogHandler.swift
//  HemuLock
//
//  Created by GitHub Copilot on 2026/1/2.
//

import Foundation
import Logging

/// A log handler that writes log messages to a file with daily rotation.
struct FileLogHandler: LogHandler {
    // MARK: - Properties
    
    private let fileHandle: FileHandle
    private let logFileURL: URL
    private let label: String
    private let dateFormatter: DateFormatter
    private let queue = DispatchQueue(label: "\(AppInfoHelper.shared.bundleIdentifier).FileLogHandler", qos: .utility)
    
    var logLevel: Logger.Level = .info
    var metadata: Logger.Metadata = [:]
    
    // MARK: - Initialization
    
    init(label: String, logDirectory: URL) throws {
        self.label = label
        
        // Create logs directory if it doesn't exist
        try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        
        // Generate log file name with current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let logFileName = "hemulock-\(dateString).log"
        
        self.logFileURL = logDirectory.appendingPathComponent(logFileName)
        
        // Create or open log file
        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil)
        }
        
        self.fileHandle = try FileHandle(forWritingTo: logFileURL)
        self.fileHandle.seekToEndOfFile()
        
        // Initialize date formatter for log timestamps
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    // MARK: - LogHandler Protocol
    
    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return metadata[key]
        }
        set {
            metadata[key] = newValue
        }
    }
    
    func log(level: Logger.Level,
             message: Logger.Message,
             metadata: Logger.Metadata?,
             source: String,
             file: String,
             function: String,
             line: UInt) {
        
        let timestamp = dateFormatter.string(from: Date())
        let levelString = levelString(for: level)
        let sourceString = source.isEmpty ? label : source
        
        // Merge metadata
        var effectiveMetadata = self.metadata
        if let metadata = metadata {
            effectiveMetadata.merge(metadata) { _, new in new }
        }
        
        // Format: [timestamp] [level] [source] message [metadata]
        var logLine = "[\(timestamp)] [\(levelString)] [\(sourceString)] \(message)"
        
        if !effectiveMetadata.isEmpty {
            let metadataString = effectiveMetadata.map { "\($0)=\($1)" }.joined(separator: " ")
            logLine += " [\(metadataString)]"
        }
        
        logLine += "\n"
        
        // Write to file on background queue
        queue.async {
            if let data = logLine.data(using: .utf8) {
                self.fileHandle.write(data)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func levelString(for level: Logger.Level) -> String {
        switch level {
        case .trace:
            return "TRACE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .notice:
            return "NOTICE"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .critical:
            return "CRITICAL"
        }
    }
}
