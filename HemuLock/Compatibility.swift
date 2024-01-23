//
//  Compatibility.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import AppKit
import Foundation

extension String {
    func abbreviated(to maxLength: Int) -> String {
        guard maxLength > 0 else {
            return ""
        }

        var length = 0
        var result = ""
        for character in self {
            let characterLength = character.isASCII ? 1 : 2
            if length + characterLength <= maxLength {
                result.append(character)
                length += characterLength
            } else {
                break
            }
        }

        if result.count < count {
            result.append("...")
        }

        return result
    }

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension NSMenuItem {
    var maxTitleLength: Int {
        get {
            return UserDefaults.standard.integer(forKey: "MaxTitleLength")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MaxTitleLength")
        }
    }

    var abbreviatedTitle: String {
        let maxLength = maxTitleLength
        guard maxLength > 0 else {
            return title
        }
        if title.count <= maxLength {
            return title
        }
        let abbreviation = "..."
        let headLength = (maxLength - abbreviation.count) / 2
        let tailLength = maxLength - abbreviation.count - headLength
        let headIndex = title.index(title.startIndex, offsetBy: headLength)
        let tailIndex = title.index(title.endIndex, offsetBy: -tailLength)
        let abbreviatedTitle = "\(title[..<headIndex])\(abbreviation)\(title[tailIndex...])"
        return abbreviatedTitle
    }

    func setTitleAndAbbreviate(_ newTitle: String) {
        title = newTitle.abbreviated(to: maxTitleLength)
    }
}

extension Date {
    func localDate() -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else { return Date() }

        return localDate
    }

    func toLocalString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
