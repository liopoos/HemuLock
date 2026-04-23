//
//  KeepAwakeDuration.swift
//  HemuLock
//
//  Created by hades on 2024/1/22.
//

import Foundation

enum KeepAwakeDuration: Int, CaseIterable {
    case permanent = 2001
    case thirtyMinutes = 2002
    case oneHour = 2003
    case fourHours = 2004
    case eightHours = 2005

    var tag: Int {
        return rawValue
    }

    // nil = indefinite (no -t flag passed to caffeinate)
    var seconds: Int? {
        switch self {
        case .permanent:      return nil
        case .thirtyMinutes:  return 30 * 60
        case .oneHour:        return 60 * 60
        case .fourHours:      return 4 * 60 * 60
        case .eightHours:     return 8 * 60 * 60
        }
    }

    /// Localization key used for the menu item title.
    var localizationKey: String {
        switch self {
        case .permanent:      return "KEEP_AWAKE_PERMANENT"
        case .thirtyMinutes:  return "KEEP_AWAKE_30_MIN"
        case .oneHour:        return "KEEP_AWAKE_1_HOUR"
        case .fourHours:      return "KEEP_AWAKE_4_HOURS"
        case .eightHours:     return "KEEP_AWAKE_8_HOURS"
        }
    }
}
