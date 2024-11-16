//
//  SQLiteManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/20.
//

import Foundation
import SQLite

class SQLiteManager {
    private var db: Connection?
    private var table: Table?
    private var path: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    init(dbName: String, tableName: String) {
        db = try! Connection(path.appendingPathComponent("\(dbName).sqlite").path)
        table = Table(tableName)
    }

    func getDb() -> Connection {
        return db!
    }

    func getTable() -> Table {
        return table!
    }

    func getPath() -> URL {
        return path
    }
}
