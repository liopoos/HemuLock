//
//  AppStateContainer.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import Foundation
import Logging

class AppStateContainer: ObservableObject {
    private let logger = LogManager.shared.logger(for: "AppStateContainer")
    
    @Published var appConfig: AppConfig {
        didSet {
            logger.trace("Save appConfig to UserDefaults")
            DefaultsManager.shared.setConfig(appConfig)
        }
    }

    init() {
        appConfig = DefaultsManager.shared.getConfig()
    }
}
