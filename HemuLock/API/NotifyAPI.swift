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
    case bark(server: String, device: String, title: String, message: String, level: String)
}

extension NotifyAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .pushover:
            return URL(string: "https://api.pushover.net/1/messages.json")!
        case let .bark(server, device, title, message, _):
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
        case let .bark(_, _, _, _, level):
            return .requestParameters(parameters: ["group": "HemuLock", "icon": "https://s3.bmp.ovh/imgs/2024/11/15/28e3a5070f9b767a.png", "level": level, "volume": 5], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return ["x-source": "hemulock"]
    }
}
