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

    struct Servercat: Decodable, Encodable {
        var sk: String = ""
    }

    struct Bark: Decodable, Encodable {
        var server: String = "bark.day.app"
        var device: String = ""
    }

    var pushover: Pushover = Pushover()
    var servercat: Servercat = Servercat()
    var bark: Bark = Bark()
}
