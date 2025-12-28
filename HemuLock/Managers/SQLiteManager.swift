//
//  SQLiteManager.swift
//  HemuLock
//
//  Created by hades on 2024/1/20.
//

import Foundation
import SQLite

/**
 SQLiteManager provides a wrapper around SQLite.swift for database operations.
 
 This manager initializes and manages a SQLite database connection and table.
 It encapsulates the database and table references, providing a simple interface
 for repository classes to perform CRUD operations.
 */
class SQLiteManager {
    /// The SQLite database connection
    private var db: Connection?
    
    /// The table reference for database operations
    private var table: Table?
    
    /// The directory path where the database file is stored
    private var path: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    /**
     Initialize the SQLite manager with a database and table name.
     
     This constructor creates or opens a SQLite database file in the documents directory
     and initializes a table reference for the specified table name.
     
     - Parameters:
       - dbName: The name of the database file (without .sqlite extension)
       - tableName: The name of the table to operate on
     */
    init(dbName: String, tableName: String) {
        db = try! Connection(path.appendingPathComponent("\(dbName).sqlite").path)
        table = Table(tableName)
    }

    // MARK: - Database Access
    
    /**
     Get the database connection.
     
     - Returns: The SQLite database connection
     */
    func getDb() -> Connection {
        return db!
    }

    /**
     Get the table reference.
     
     - Returns: The table reference for database operations
     */
    func getTable() -> Table {
        return table!
    }

    /**
     Get the database file directory path.
     
     - Returns: The URL of the directory containing the database file
     */
    func getPath() -> URL {
        return path
    }
}
