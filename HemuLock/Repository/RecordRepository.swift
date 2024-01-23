//
//  RecordRepository.swift
//  HemuLock
//
//  Created by hades on 2024/1/20.
//

import Foundation
import SQLite

class RecordRepository {
    static let shared = RecordRepository()

    let id = Expression<Int>("id")
    let event = Expression<String>("event")
    let isNotify = Expression<Bool>("is_notify")
    let time = Expression<Date>("time")

    var dbManager: SQLiteManager
    var db: Connection
    var table: Table

    init() {
        dbManager = SQLiteManager(dbName: "hemu_data", tableName: "record")
        db = dbManager.getDb()
        table = dbManager.getTable()

        // Attempt create table.
        try! db.run(table.create(ifNotExists: true) { builder in
            builder.column(id, primaryKey: .autoincrement)
            builder.column(event)
            builder.column(isNotify)
            builder.column(time)
        })
    }

    /**
     Get record list from db.
     */
    func getRecords(limit: Int = 0) -> [Record] {
        var list: [Record] = []
        do {
            let query = limit > 0 ? table.limit(limit) : table
            let records = try db.prepare(query.order(time.desc))
            for record in records {
                list.append(Record(id: try record.get(id), event: try record.get(event), isNotify: try record.get(isNotify), time: try record.get(time)))
            }
        } catch { return list }

        return list
    }

    /**
     Add record to db.
     */
    func insertRecord(record: Record) -> Bool {
        do {
            try db.run(table.insert(event <- record.event, isNotify <- record.isNotify, time <- record.time))
        } catch { return false }

        return true
    }

    /**
     Delete record in table.
     */
    func dropRecord() -> Bool {
        do {
            try db.run(table.delete())
        } catch { return false }

        return true
    }
}
