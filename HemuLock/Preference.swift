//
//  Preference.swift
//  hemu
//
//  Created by hades on 2021/4/6.
//
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

struct Preference: Decodable, Encodable {
    var notify: NotifyData
}

