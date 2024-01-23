//
//  NotifyType.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import Foundation

enum Notify: Int, CaseIterable, Codable {
    case none = 0
    case pushover = 1
    case serverCat = 2
    case bark = 3

    var tag: Int {
        return rawValue
    }

    var name: String {
        switch self {
        case .none:
            return "NOTIFY_NONE".localized
        case .pushover:
            return "NOTIFY_PUSHOVER".localized
        case .serverCat:
            return "NOTIFY_SERVERCAT".localized
        case .bark:
            return "NOTIFY_BARK".localized
        }
    }
}
