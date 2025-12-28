//
//  DefaultsManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import DefaultsKit
import Foundation
import LaunchAtLogin

/**
 DefaultsManager handles all application configuration persistence operations.
 
 This manager provides a wrapper around DefaultsKit to save and retrieve
 the application configuration from UserDefaults. It ensures a single source
 of truth for configuration storage.
 */
class DefaultsManager {
    static let shared = DefaultsManager()

    let defaults = Defaults.shared
    let key = Key<AppConfig>("app_config")

    // MARK: - Configuration Management
    
    /**
     Save the application configuration to UserDefaults.
     
     - Parameter appConfig: The application configuration to persist
     */
    public func setConfig(_ appConfig: AppConfig) {
        defaults.set(appConfig, for: key)
    }

    /**
     Retrieve the application configuration from UserDefaults.
     
     - Returns: The saved AppConfig, or a default AppConfig if none exists
     */
    public func getConfig() -> AppConfig {
        guard let appConfig = defaults.get(for: key) else {
            return AppConfig()
        }

        return appConfig
    }
}
