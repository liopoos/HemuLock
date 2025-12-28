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
 
 - Note: Uses failable initializer to handle database connection errors gracefully
 */
class SQLiteManager {
    // MARK: - Properties
    
    /// The SQLite database connection
    private let db: Connection
    
    /// The table reference for database operations
    private let table: Table
    
    /// The full path to the database file
    private let databasePath: URL
    
    // MARK: - Initialization
    
    /**
     Initialize the SQLite manager with a database and table name.
     
     This constructor creates or opens a SQLite database file in the documents directory
     and initializes a table reference for the specified table name.
     
     - Parameters:
       - dbName: The name of the database file (without .sqlite extension)
       - tableName: The name of the table to operate on
     
     - Throws: An error if the database directory cannot be found or database connection fails
     */
    init(dbName: String, tableName: String) throws {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "SQLiteManager", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: "Could not locate documents directory"])
        }
        
        self.databasePath = documentsPath.appendingPathComponent("\(dbName).sqlite")
        self.db = try Connection(databasePath.path)
        self.table = Table(tableName)
    }

    // MARK: - Database Access
    
    /**
     Get the database connection.
     
     - Returns: The SQLite database connection instance
     */
    func getDb() -> Connection {
        return db
    }

    /**
     Get the table reference.
     
     - Returns: The table reference for database operations
     */
    func getTable() -> Table {
        return table
    }

    /**
     Get the database file path.
     
     - Returns: The full URL path to the database file
     */
    func getDatabasePath() -> URL {
        return databasePath
    }
    
    /**
     Get the database file directory path.
     
     - Returns: The URL of the directory containing the database file
     */
    func getPath() -> URL {
        return databasePath.deletingLastPathComponent()
    }
}
