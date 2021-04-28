//
//  Notify.swift
//  hemu
//
//  Created by hades on 2021/4/1.
//
import Foundation

class Notify: NSObject {
    var type = 0
    
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
        self.sendRequest(method: "POST", url: "https://api.pushover.net/1/messages.json", params:  "token=\(config.token)&user=\(config.user)&device=\(config.device)&title=\(title)&message=\(message)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    }
}
