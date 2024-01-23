//
//  NotifyError.swift
//  HemuLock
//
//  Created by hades on 2024/1/20.
//

import Foundation

enum NotifyError: Error {
    case invalidConfig
    case requestFailed

    var message: String {
        switch self {
        case .invalidConfig:
            return "CONFIG_INVALID"
        case .requestFailed:
            return "REQUEST_ERROR"
        }
    }
}
