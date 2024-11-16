//
//  NotiftManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import Foundation
import Moya

class NotifyManager {
    static let shared = NotifyManager()

    private let provider = MoyaProvider<NotifyAPI>()

    func send(title: String, message: String) throws -> Bool {
        let config = appState.appConfig.notifyConfig
        let api: NotifyAPI

        switch appState.appConfig.notifyType {
        case Notify.pushover.tag:
            if config.pushover.token.isEmpty || config.pushover.user.isEmpty {
                throw NotifyError.invalidConfig
            }
            api = .pushover(user: config.pushover.user, token: config.pushover.token, device: config.pushover.device, title: title, message: message)
        case Notify.serverCat.tag:
            if config.servercat.sk.isEmpty {
                throw NotifyError.invalidConfig
            }
            api = .serverCat(sk: config.servercat.sk, title: title, message: message)
        case Notify.bark.tag:
            if config.bark.server.isEmpty || config.bark.device.isEmpty {
                throw NotifyError.invalidConfig
            }
            api = .bark(server: config.bark.server, device: config.bark.device, title: title, message: message, level: config.bark.critical ? "critical" : "")
        default:
            return false
        }

        // Send notify.
        provider.request(api) { result in
            switch result {
            case .success:
                print("send notify success")
            case let .failure(error):
                print("send notify failed: \(error)")
            }
        }

        return true
    }
}
