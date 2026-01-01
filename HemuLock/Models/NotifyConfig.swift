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
        
        enum CodingKeys: String, CodingKey {
            case token, user, device
        }
        
        init() {}
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            token = (try? container.decode(String.self, forKey: .token)) ?? ""
            user = (try? container.decode(String.self, forKey: .user)) ?? ""
            device = (try? container.decode(String.self, forKey: .device)) ?? ""
        }
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
        
        enum CodingKeys: String, CodingKey {
            case server, device, critical
        }
        
        init() {}
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            server = (try? container.decode(String.self, forKey: .server)) ?? "bark.day.app"
            device = (try? container.decode(String.self, forKey: .device)) ?? ""
            critical = (try? container.decode(Bool.self, forKey: .critical)) ?? false
        }
    }

    var pushover: Pushover = Pushover()
    var bark: Bark = Bark()
    
    // MARK: - Custom Decoding
    
    enum CodingKeys: String, CodingKey {
        case pushover, bark
        // Explicitly ignoring old 'servercat' field by not including it
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pushover = (try? container.decode(Pushover.self, forKey: .pushover)) ?? Pushover()
        bark = (try? container.decode(Bark.self, forKey: .bark)) ?? Bark()
    }
}
