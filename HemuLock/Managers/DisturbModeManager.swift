//
//  DisturbModeManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/23.
//

import Foundation

class DisturbModeManager {
    static let shared = DisturbModeManager()

    /**
     weather in disturb time.
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
