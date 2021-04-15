//
//  ConfigKey.swift
//  hemu
//
//  Created by hades on 2021/4/1.
//

struct ConfigKey {
    struct app {
        static let login = "app.launch_login"
        static let preferences = "app.set_preferences"
    }
    
    struct event {
        static let list = "event.list"
    }
    
    struct notify {
        static let type = "notify.type"
    }
    
    struct action {
        static let script = "action.set_script"
    }
}
