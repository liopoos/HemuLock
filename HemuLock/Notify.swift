//
//  Notify.swift
//  hemu
//
//  Created by hades on 2021/4/1.
//

import Foundation

class Notify: NSObject {
    var type = 0
    let configPath = NSHomeDirectory() + "/.hemu" //config file
    let fileManager = FileManager.default
    
    func sendRequest(method: String, url: String, params: String = ""){
        var request = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = method
        
        if method == "POST" {
            let data = params.data(using: .utf8)
            request.httpBody = data
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, respons, error) in
            if data == nil {return}
            if respons == nil {return}
        }
        dataTask.resume()
    }
    
    func sendServerCat(config: Servercat, title: String, message: String) {
        if config.sk.isEmpty { return }
        self.sendRequest(method: "GET", url: "https://sc.ftqq.com/\(config.sk).send?text=\(title)&desp=\(message)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    }
    
    func sendPushover(config: Pushover, title: String, message: String) {
        if config.token.isEmpty && config.user.isEmpty { return }
        self.sendRequest(method: "POST", url: "https://api.pushover.net/1/messages.json", params:  "token=\(config.token)&user=\(config.user)&title=\(title)&message=\(message)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    }
    
    func getNotifyConfig() -> Preference {
        let defaultPreference = Preference.init(notify: NotifyData.init(pushover: Pushover.init(token: "", user: ""), servercat: Servercat.init(sk: "")))
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
    
    func setNotifyConfig(config: Preference) {
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
}
