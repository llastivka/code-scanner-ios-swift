import UIKit
import Foundation
import SQLite3

class DBManager {
    
    init()
    {
        db = openDatabase()
    }
    
    // The database pointer.
    var db: OpaquePointer?
    var databaseFileName = "database1.sqlite"
    
    func openDatabase() -> OpaquePointer?
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(databaseFileName)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(databaseFileName)")
            return db
        }
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Records (recordId INTEGER PRIMARY KEY, message TEXT, notes TEXT, date TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("Records table created.")
            } else {
                print("Records table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insert(record : HistoryRecord)
    {
        let historyRecords = read()
        for r in historyRecords
        {
            if r.recordId == record.recordId
            {
                return
            }
        }
        let insertStatementString = "INSERT INTO Records (recordId, message, notes, date) VALUES (?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(record.recordId))
            sqlite3_bind_text(insertStatement, 2, (record.message as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (record.notes as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (record.date as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func read() -> [HistoryRecord] {
        let queryStatementString = "SELECT * FROM Records;"
        var queryStatement: OpaquePointer? = nil
        var historyRecords : [HistoryRecord] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let message = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let notes = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let date = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                historyRecords.append(HistoryRecord(recordId: Int(id), message: message, notes : notes, date : date))
                print("Query Result:")
                print("\(id) | \(message) | \(notes) | \(date)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return historyRecords
    }
    
    func readById(id : Int) -> HistoryRecord {
        let queryStatementString = "SELECT * FROM Records WHERE recordId = ?;"
        var queryStatement: OpaquePointer? = nil
        var historyRecord : HistoryRecord? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                sqlite3_bind_int(queryStatement, 1, Int32(id))
                let recordId = sqlite3_column_int(queryStatement, 0)
                let message = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let notes = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let date = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                historyRecord = HistoryRecord(recordId: Int(recordId), message: message, notes : notes, date : date)
                print("Query Result:")
                print("\(id) | \(message) | \(notes) | \(date)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return historyRecord!
    }
    
    func deleteByID(id : Int) {
        let deleteStatementStirng = "DELETE FROM Records WHERE recordId = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
}
