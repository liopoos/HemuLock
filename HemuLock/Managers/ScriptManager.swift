//
//  ScriptManager.swift
//  HemuLock
//
//  Created by hades on 2024/11/16.
//
import Cocoa

class ScriptManager {
    static let shared = ScriptManager()

    private let path: URL
    private lazy var file: URL = { path.appendingPathComponent("script") }()

    private init() {
        do {
            path = try FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            print("Failed to get applicationScriptsDirectory: \(error)")
            path = FileManager.default.temporaryDirectory
        }
    }

    func getPath() -> URL {
        return path
    }
    
    func getFile() -> URL {
        return file
    }
}
