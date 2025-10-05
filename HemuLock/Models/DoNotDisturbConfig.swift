//
//  DoNotDisturb.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import Foundation

struct DoNotDisturbConfig: Codable {
    struct DoNotDisturbType: Codable {
        var script: Bool = true
        var notify: Bool = true
    }

    struct DoNotDisturbCycle: Codable {
        var monday: Bool = false
        var tuesday: Bool = false
        var wednesday: Bool = false
        var thursday: Bool = false
        var firday: Bool = false
        var saturday: Bool = false
        var sunday: Bool = false
    }

    var start: String = "00:00"
    var end: String = "23:59"
    var type: DoNotDisturbType = DoNotDisturbType()
    var cycle: DoNotDisturbCycle = DoNotDisturbCycle()
}
