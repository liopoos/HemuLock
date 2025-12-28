//
//  Notify.swift
//  hemu
//
//  Created by hades on 2021/4/1.
//
import Foundation

struct NotifyConfig: Codable {
    struct Pushover: Decodable, Encodable {
        var token: String = ""
        var user: String = ""
        var device: String = ""
    }

    struct Bark: Decodable, Encodable {
        var server: String = "bark.day.app" {
            didSet {
                server = server
                    .replacingOccurrences(of: "https://", with: "")
                    .replacingOccurrences(of: "http://", with: "")
            }
        }

        var device: String = ""
        var critical: Bool = false
    }

    var pushover: Pushover = Pushover()
    var bark: Bark = Bark()
}
