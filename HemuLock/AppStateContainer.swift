//
//  AppStateContainer.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import Foundation

class AppStateContainer: ObservableObject {
    @Published var appConfig: AppConfig {
        didSet {
            print("Save appConfig to UserDefaults")
            DefaultsManager.shared.setConfig(appConfig)
        }
    }

    init() {
        appConfig = DefaultsManager.shared.getConfig()
    }
}
