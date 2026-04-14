//
//  ScriptManager.swift
//  HemuLock
//
//  Created by hades on 2024/11/16.
//
import Cocoa
import Logging

/**
 ScriptManager handles user script management and execution.
 
 This manager manages the sandboxed script directory location and provides
 access to the user's custom script file. Scripts are stored in the
 application's designated scripts directory (~/Library/Application Scripts/com.cyberstack.HemuLock/)
 as required by macOS sandboxing.
 */
class ScriptManager {
    static let shared = ScriptManager()
    private let logger = LogManager.shared.logger(for: "ScriptManager")

    /// The sandboxed application scripts directory
    private let path: URL
    
    /// The user's script file location
    private lazy var file: URL = { path.appendingPathComponent("script") }()

    /**
     Initialize the script manager and ensure the scripts directory exists.
     
     This constructor locates or creates the application's scripts directory.
     If the directory cannot be created, falls back to the temporary directory.
     */
    private init() {
        do {
            path = try FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            logger.error("Failed to get applicationScriptsDirectory: \(error)")
            path = FileManager.default.temporaryDirectory
        }
    }

    // MARK: - Path Access
    
    /**
     Get the application scripts directory path.
     
     - Returns: The URL of the sandboxed scripts directory
     */
    func getPath() -> URL {
        return path
    }
    
    /**
     Get the user's script file path.
     
     - Returns: The URL of the script file (path/script)
     */
    func getFile() -> URL {
        return file
    }
}
