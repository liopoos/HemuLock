//
//  MenuItem.swift
//  HemuLock
//
//  Created by hades on 2024/1/22.
//

import Foundation

enum MenuItem: Int, CaseIterable {
    case appInfo = 1001
    case event = 1002
    case notify = 1003
    case notifyTest = 1004

    case setScript = 1005
    case setDoNotDisturb = 1006
    case setLaunchAtLogin = 1007
    case setEventRecord = 1008
    
    case eventRecord = 1009
    case features = 1010
    case setWebhook = 1011

    var tag: Int {
        return rawValue
    }
}
