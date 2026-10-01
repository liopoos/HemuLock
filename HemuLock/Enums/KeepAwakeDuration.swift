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

enum KeepAwakePreset: Int, CaseIterable {
    case tonight = 1015
    case midnight = 1016

    var tag: Int { rawValue }

    var localizationKey: String {
        switch self {
        case .tonight: return "KEEP_AWAKE_PRESET_TONIGHT"
        case .midnight: return "KEEP_AWAKE_PRESET_MIDNIGHT"
        }
    }

    func deadline(from date: Date = Date(), calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = self == .tonight ? 21 : 23
        components.minute = self == .tonight ? 0 : 59
        components.second = 0
        return calendar.date(from: components) ?? date
    }
}

enum KeepAwakeOption: Int, CaseIterable, Identifiable {
    case permanent = 2001
    case thirtyMinutes = 2002
    case oneHour = 2003
    case fourHours = 2004
    case eightHours = 2005
    case tonight = 1015
    case midnight = 1016

    var id: Int { rawValue }

    var localizationKey: String {
        if let duration = KeepAwakeDuration(rawValue: rawValue) {
            return duration.localizationKey
        }
        return KeepAwakePreset(rawValue: rawValue)?.localizationKey ?? ""
    }

    var duration: KeepAwakeDuration? {
        KeepAwakeDuration(rawValue: rawValue)
    }

    var preset: KeepAwakePreset? {
        KeepAwakePreset(rawValue: rawValue)
    }
}
