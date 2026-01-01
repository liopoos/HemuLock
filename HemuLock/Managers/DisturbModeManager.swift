//
//  DisturbModeManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/23.
//

import Foundation

/**
 DisturbModeManager manages the Do Not Disturb functionality of the application.
 
 This manager determines whether the current time falls within the user-configured
 Do Not Disturb period, checking both the time range and weekday settings.
 It is used to block notifications and script execution during disturb periods.
 */
class DisturbModeManager {
    static let shared = DisturbModeManager()

    // MARK: - Disturb Status Check
    
    /**
     Check whether the current time is within the Do Not Disturb period.
     
     This method evaluates:
     - Whether Do Not Disturb is enabled
     - Whether the current weekday is included in the disturb cycle
     - Whether the current time falls within the configured time range
     
     - Returns: true if currently in disturb mode, false otherwise
     */
    func inDisturb() -> Bool {
        if !appState.appConfig.isDoNotDisturb {
            return false
        }

        let disturbConfig = appState.appConfig.doNotDisturbConfig

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let now = date.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
        let weekDay = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekday, Calendar.Component.day], from: date).weekday
        var inWeekDay = false

        switch weekDay {
        case 1:
            inWeekDay = disturbConfig.cycle.sunday
        case 2:
            inWeekDay = disturbConfig.cycle.monday
        case 3:
            inWeekDay = disturbConfig.cycle.tuesday
        case 4:
            inWeekDay = disturbConfig.cycle.wednesday
        case 5:
            inWeekDay = disturbConfig.cycle.thursday
        case 6:
            inWeekDay = disturbConfig.cycle.firday
        case 7:
            inWeekDay = disturbConfig.cycle.saturday
        default:
            inWeekDay = false
        }
        if !inWeekDay { return false }

        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: now)

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let doNotDisturbStart = dateFormatter.date(from: "\(todayDate) \(disturbConfig.start):00")
        let doNotDisturbEnd = dateFormatter.date(from: "\(todayDate) \(disturbConfig.end):59")
        if now.compare(doNotDisturbStart!) == .orderedDescending && now.compare(doNotDisturbEnd!) == .orderedAscending {
            return true
        }

        return false
    }
}
