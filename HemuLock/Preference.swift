//
//  Preference.swift
//  hemu
//
//  Created by hades on 2021/4/6.
//
import Foundation

let configPath = NSHomeDirectory() + "/.config" //config file
let fileManager = FileManager.default

var appConfig = getPrefercenceConfig()

struct Pushover: Decodable, Encodable {
    var token: String
    var user: String
}

struct Servercat: Decodable, Encodable {
    var sk: String
}

struct NotifyData: Decodable, Encodable {
    var pushover: Pushover
    var servercat: Servercat
}

struct DoNotDisturbData: Decodable, Encodable {
    var start: String
    var end: String
    var cycle: DoNotDisturbCycle
    var type: DoNotDisturbType
    
}

struct Preference: Decodable, Encodable {
    var notify: NotifyData
    var do_no_disturb: DoNotDisturbData
}

struct DoNotDisturbCycle: Decodable, Encodable {
    var monday : Bool = false
    var tuesday : Bool = false
    var wednesday : Bool = false
    var thursday : Bool = false
    var firday : Bool = false
    var saturday : Bool = false
    var sunday : Bool = false
}

struct DoNotDisturbType: Decodable, Encodable {
    var script: Bool = true
    var notify: Bool = true
}

func initPreference() -> Preference {
    return Preference.init(notify: NotifyData.init(pushover: Pushover.init(token: "", user: ""), servercat: Servercat.init(sk: "")), do_no_disturb: DoNotDisturbData.init(start: "00:00", end: "23:59", cycle: DoNotDisturbCycle.init(), type: DoNotDisturbType.init()))
}


func getPrefercenceConfig() -> Preference {
    let defaultPreference = initPreference()
    let isExist = fileManager.fileExists(atPath: configPath)
    if !isExist {
        guard let srcPath = Bundle.main.path(forResource: "config.json", ofType: nil) else {
            return defaultPreference
        }
        try! fileManager.copyItem(atPath: srcPath, toPath: configPath)
    }
    let data = fileManager.contents(atPath: configPath)!
    guard let preference = try? JSONDecoder().decode(Preference.self, from: data) else{
        return defaultPreference
    }
    return preference
}

func setPrefercenceConfig(config: Preference) {
    appConfig = config
    let isExist = fileManager.fileExists(atPath: configPath)
    if !isExist {
        guard let srcPath = Bundle.main.path(forResource: "config.json", ofType: nil) else {
            return
        }
        try! fileManager.copyItem(atPath: srcPath, toPath: configPath)
    }
    let jsonConfig = try? JSONEncoder().encode(config)
    try? jsonConfig?.write(to: URL(fileURLWithPath: configPath))
}

func formatDateByString(date: String) -> Date {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "HH:mm"
    return dateFormater.date(from: date) ?? Date.init()
}

func formatDateByDate(date: Date) -> String {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "HH:mm"
    return dateFormater.string(from: date)
}

func inDisturb(config: DoNotDisturbData) -> Bool {
    // get config
    if !UserDefaults.standard.bool(forKey: ConfigKey.app.do_not_disturb) { return false }
    
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
    let now = date.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
    // get weekday
    let weekDay = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekday, Calendar.Component.day], from: date).weekday
    var inWeekDay = false
    
    switch weekDay {
    case 1:
        inWeekDay = config.cycle.sunday
    case 2:
        inWeekDay = config.cycle.monday
    case 3:
        inWeekDay = config.cycle.tuesday
    case 4:
        inWeekDay = config.cycle.wednesday
    case 5:
        inWeekDay = config.cycle.thursday
    case 6:
        inWeekDay = config.cycle.firday
    case 7:
        inWeekDay = config.cycle.saturday
    default:
        inWeekDay = false
    }
    if !inWeekDay { return false }
    
    // get today date
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let todayDate = dateFormatter.string(from: now)
    
    // format do not disturb start
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    let doNotDisturbStart = dateFormatter.date(from: "\(todayDate) \(config.start)")
    let doNotDisturbEnd = dateFormatter.date(from: "\(todayDate) \(config.end)")
    if now.compare(doNotDisturbStart!) == .orderedDescending && now.compare(doNotDisturbEnd!) == .orderedAscending { return true }
    
    return false
}
