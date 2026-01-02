//
//  AppInfoHelper.swift
//  HemuLock
//
//  Created by GitHub Copilot on 2026/1/2.
//

import Foundation

/// A utility class for accessing common app bundle information.
class AppInfoHelper {
    
    // MARK: - Singleton
    
    static let shared = AppInfoHelper()
    
    private init() {}
    
    // MARK: - Bundle Information
    
    /// The app's bundle identifier (e.g., "com.cyberstack.HemuLock")
    var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.cyberstack.HemuLock"
    }
    
    /// The app's display name
    var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "HemuLock"
    }
    
    /// The app's version string (e.g., "1.0.0")
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// The app's build number (e.g., "100")
    var appBuild: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// The full app version string including build number (e.g., "HemuLock v1.0.0(100)")
    var fullVersionString: String {
        return "\(appName) v\(appVersion)(\(appBuild))"
    }
    
    // MARK: - Sandboxed Directories
    
    /// The sandboxed application scripts directory path
    /// Returns: ~/Library/Application Scripts/{bundleIdentifier}/
    var scriptDirectory: URL {
        let appScriptsURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask).first!
        return appScriptsURL.appendingPathComponent(bundleIdentifier)
    }
    
    /// The app support directory path for logs
    /// Returns: ~/Library/Application Support/{bundleIdentifier}/
    var appSupportDirectory: URL {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupportURL.appendingPathComponent(bundleIdentifier)
    }
    
    /// The logs directory path
    /// Returns: ~/Library/Application Support/{bundleIdentifier}/Logs/
    var logsDirectory: URL {
        return appSupportDirectory.appendingPathComponent("Logs")
    }
}
