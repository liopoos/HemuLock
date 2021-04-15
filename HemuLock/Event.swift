//
//  Event.swift
//  hemu
//
//  Created by hades on 2021/4/1.
//

import Foundation

class Event: NSObject {
    var list = [Event.tag.system_lock, Event.tag.system_unlock]
    
    struct tag {
        static let screen_sleep = 10
        static let screen_wake = 11
        static let system_sleep = 20
        static let system_wake = 21
        static let system_lock = 30
        static let system_unlock = 31
    }
    
    struct flag {
        static let screen_sleep = "SCREEN_SLEEP"
        static let screen_wake = "SCREEN_WAKE"
        static let system_sleep = "SYSTEM_SLEEP"
        static let system_wake = "SYSTEM_WAKE"
        static let system_lock = "SYSTEM_LOCK"
        static let system_unlock = "SYSTEM_UNLOCK"
    }
    
    struct string {
        static let screen_sleep = "screen_sleep"
        static let screen_wake = "screen_wake"
        static let system_sleep = "system_sleep"
        static let system_wake = "system_wake"
        static let system_lock = "system_lock"
        static let system_unlock = "system_unlock"
    }
}
