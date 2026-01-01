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
        
        enum CodingKeys: String, CodingKey {
            case script, notify
        }
        
        init() {}
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            script = (try? container.decode(Bool.self, forKey: .script)) ?? true
            notify = (try? container.decode(Bool.self, forKey: .notify)) ?? true
        }
    }

    struct DoNotDisturbCycle: Codable {
        var monday: Bool = false
        var tuesday: Bool = false
        var wednesday: Bool = false
        var thursday: Bool = false
        var firday: Bool = false
        var saturday: Bool = false
        var sunday: Bool = false
        
        enum CodingKeys: String, CodingKey {
            case monday, tuesday, wednesday, thursday, firday, saturday, sunday
        }
        
        init() {}
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            monday = (try? container.decode(Bool.self, forKey: .monday)) ?? false
            tuesday = (try? container.decode(Bool.self, forKey: .tuesday)) ?? false
            wednesday = (try? container.decode(Bool.self, forKey: .wednesday)) ?? false
            thursday = (try? container.decode(Bool.self, forKey: .thursday)) ?? false
            firday = (try? container.decode(Bool.self, forKey: .firday)) ?? false
            saturday = (try? container.decode(Bool.self, forKey: .saturday)) ?? false
            sunday = (try? container.decode(Bool.self, forKey: .sunday)) ?? false
        }
    }

    var start: String = "00:00"
    var end: String = "23:59"
    var type: DoNotDisturbType = DoNotDisturbType()
    var cycle: DoNotDisturbCycle = DoNotDisturbCycle()
    
    // MARK: - Custom Decoding
    
    enum CodingKeys: String, CodingKey {
        case start, end, type, cycle
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = (try? container.decode(String.self, forKey: .start)) ?? "00:00"
        end = (try? container.decode(String.self, forKey: .end)) ?? "23:59"
        type = (try? container.decode(DoNotDisturbType.self, forKey: .type)) ?? DoNotDisturbType()
        cycle = (try? container.decode(DoNotDisturbCycle.self, forKey: .cycle)) ?? DoNotDisturbCycle()
    }
}
