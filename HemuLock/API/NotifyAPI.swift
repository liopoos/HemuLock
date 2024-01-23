//
//  NotifyAPI.swift
//  HemuLock
//
//  Created by hades on 2024/1/20.
//

import Foundation
import Moya

enum NotifyAPI {
    case pushover(user: String, token: String, device: String, title: String, message: String)
    case bark(server: String, device: String, title: String, message: String)
    case serverCat(sk: String, title: String, message: String)
}

extension NotifyAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .pushover:
            return URL(string: "https://api.pushover.net/1/messages.json")!
        case let .serverCat(sk, _, _):
            return URL(string: "https://sc.ftqq.com/\(sk).send")!
        case let .bark(server, device, title, message):
            return URL(string: "https://\(server)/\(device)/\(title)/\(message)")!
        }
    }

    var path: String {
        return ""
    }

    var method: Moya.Method {
        switch self {
        case .pushover:
            return .post
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .pushover(user, token, device, title, message):
            return .requestParameters(parameters: ["user": user, "token": token, "device": device, "title": title, "message": message], encoding: JSONEncoding.default)
        case .bark:
            return .requestParameters(parameters: ["group": "HemuLock", "icon": "https://cdn.mayuko.cn/hemulock/icon.png"], encoding: URLEncoding.queryString)
        case let .serverCat(_, title, message):
            return .requestParameters(parameters: ["text": title, "desp": message], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return ["x-source": "hemulock"]
    }
}
