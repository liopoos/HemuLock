//
//  DefaultsManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import DefaultsKit
import Foundation
import LaunchAtLogin

class DefaultsManager {
    static let shared = DefaultsManager()

    let defaults = Defaults.shared
    let key = Key<AppConfig>("app_config")

    public func setConfig(_ appConfig: AppConfig) {
        defaults.set(appConfig, for: key)
    }

    public func getConfig() -> AppConfig {
        guard let appConfig = defaults.get(for: key) else {
            return AppConfig()
        }

        return appConfig
    }
}
