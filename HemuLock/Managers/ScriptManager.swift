//
//  ScriptManager.swift
//  HemuLock
//
//  Created by hades on 2024/11/16.
//
import Cocoa

/**
 ScriptManager handles user script management and execution.
 
 This manager manages the application script directory location and provides
 access to the user's custom script file. Scripts are stored in the
 application's designated scripts directory (~/Library/Application Scripts/com.cyberstack.HemuLock/)
 as required by macOS sandboxing.
 */
class ScriptManager {
    static let shared = ScriptManager()

    /// The application scripts directory
    private let path: URL
    
    /// The user's script file location
    private lazy var file: URL = { path.appendingPathComponent("script") }()

    /**
     Initialize the script manager and locate the application's scripts directory.
     
     The sandbox grants access to this standard directory but does not grant
     permission to create it, so lookup must not request directory creation.
     */
    private init() {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.cyberstack.HemuLock"
        path = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Application Scripts")
                .appendingPathComponent(bundleIdentifier, isDirectory: true)
    }

    // MARK: - Path Access
    
    /**
     Get the application scripts directory path.
     
     - Returns: The URL of the application scripts directory
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
