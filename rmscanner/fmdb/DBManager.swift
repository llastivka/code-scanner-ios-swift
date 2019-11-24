import UIKit
import Foundation
import os.log
import SQLite3

class DBManager {
    
    let databaseFileName = "database.sqlite"
    
    let fieldRecordId = "recordId"
    let fieldMessage = "message"
    let fieldNotes = "notes"
    let fieldDate = "date"
    
    // Get the URL to db store file
    let dbURL: URL
    // The database pointer.
    var db: OpaquePointer?
    var insertEntryStmt: OpaquePointer?
    var readEntryStmt: OpaquePointer?
    var readAllEntryStmt : OpaquePointer?
    var updateEntryStmt: OpaquePointer?
    var deleteEntryStmt: OpaquePointer?
    let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
    
    let oslog = OSLog(subsystem: "rmscanner", category: "sqlitehistory")
    
    init() {
        do {
            do {
                dbURL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent(databaseFileName)
                os_log("URL: %s", dbURL.absoluteString)
            } catch {
                //TODO: Just logging the error and returning empty path URL here. Handle the error gracefully after logging
                os_log("Some error occurred. Returning empty path.")
                dbURL = URL(fileURLWithPath: "")
                return
            }
            
            try openDB()
            try createTables()
        } catch {
            //TODO: Handle the error gracefully after logging
            os_log("Some error occurred. Returning.")
            return
        }
    }
    
    // Command: sqlite3_open(dbURL.path, &db)
    // Open the DB at the given path. If file does not exists, it will create one for you
    func openDB() throws {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK { // error mostly because of corrupt database
            os_log("error opening database at %s", log: oslog, type: .error, dbURL.absoluteString)
            //            deleteDB(dbURL: dbURL)
            throw SqliteError(message: "error opening database \(dbURL.absoluteString)")
        }
    }
    
    // Code to delete a db file. Useful to invoke in case of a corrupt DB and re-create another
    func deleteDB(dbURL: URL) {
        os_log("Removing db", log: oslog)
        do {
            try FileManager.default.removeItem(at: dbURL)
        } catch {
            os_log("Exception while removing db %s", log: oslog, error.localizedDescription)
        }
    }
    
    func createTables() throws {
        // create the tables if they dont exist.
        
        // create the table to store the entries.
        let ret =  sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Records (\(fieldMessage) text not null, \(fieldNotes) text, \(fieldDate) date not null)", nil, nil, nil)
        if (ret != SQLITE_OK) { // corrupt database.
            logDbErr("Error creating db table - Records")
            throw SqliteError(message: "Unable to create table Records")
        }
        
    }
    
    func logDbErr(_ msg: String) {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        os_log("ERROR %s : %s", log: oslog, type: .error, msg, errmsg)
    }
    
    //"INSERT INTO Records (message, notes, date) VALUES (?,?,?)"
    func create(record: HistoryRecord) {
        // ensure statements are created on first usage if nil
        guard self.prepareInsertEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.insertEntryStmt)
        }
        
        //  At some places (esp sqlite3_bind_xxx functions), we typecast String to NSString and then convert to char*,
        // ex: (eventLog as NSString).utf8String. This is a weird bug in swift's sqlite3 bridging. this conversion resolves it.
        
        //Inserting message in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 1, (record.message as NSString).utf8String, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //Inserting notes in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 2, (record.notes as NSString).utf8String, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //Inserting date in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 3, (record.date as NSString).utf8String, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //executing the query to insert values
        let r = sqlite3_step(self.insertEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(insertEntryStmt) \(r)")
            return
        }
    }
    
    //"SELECT * FROM Records WHERE id = ?"
    func read(id: Int) throws -> HistoryRecord {
        // ensure statements are created on first usage if nil
        guard self.prepareReadEntryStmt() == SQLITE_OK else { throw SqliteError(message: "Error in prepareReadEntryStmt") }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.readEntryStmt)
        }
        
        //Inserting record id in readEntryStmt prepared statement
        if sqlite3_bind_int(self.readEntryStmt, 1, Int32(id)) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(readEntryStmt)")
            throw SqliteError(message: "Error in inserting value in prepareReadEntryStmt")
        }
        
        //executing the query to read value
        if sqlite3_step(readEntryStmt) != SQLITE_ROW {
            logDbErr("sqlite3_step COUNT* readEntryStmt:")
            throw SqliteError(message: "Error in executing read statement")
        }
        
        return HistoryRecord(recordId: Int(String(cString: sqlite3_column_text(readEntryStmt, 1)))!,
                      message: String(cString: sqlite3_column_text(readEntryStmt, 2)),
                      notes: String(cString: sqlite3_column_text(readEntryStmt, 3)),
                      date: String(cString: sqlite3_column_text(readEntryStmt, 4)))
                      //date: String(cString: sqlite3_column_text(readEntryStmt, 4)))
    }
    
    //"SELECT * FROM Records"
    func readAll() throws -> [HistoryRecord] {
        // ensure statements are created on first usage if nil
        guard self.prepareReadAllEntryStmt() == SQLITE_OK else { throw SqliteError(message: "Error in prepareReadEntryStmt") }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.readAllEntryStmt)
        }
        
        var historyRecords: [HistoryRecord] = []
        
        while sqlite3_step(readAllEntryStmt) == SQLITE_ROW {
            
            let historyRecord  = HistoryRecord(recordId: Int(String(cString: sqlite3_column_text(readAllEntryStmt, 1)))!,
                                                   message: String(cString: sqlite3_column_text(readAllEntryStmt, 2)),
                                                   notes: String(cString: sqlite3_column_text(readAllEntryStmt, 3)),
                                                   date: String(cString: sqlite3_column_text(readAllEntryStmt, 4)))
            historyRecords.append(historyRecord)
            
        }
        
//        guard sqlite3_step(readAllEntryStmt) == SQLITE_DONE else {
//            logDbErr("sqlite3_step COUNT* readAllEntryStmt:")
//            throw SqliteError(message: "Error in executing read statement")
//        }
        
        return historyRecords
    }
    
    //"UPDATE Records SET notes = ?"
    func update(record: HistoryRecord) {
        // ensure statements are created on first usage if nil
        guard self.prepareUpdateEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.updateEntryStmt)
        }
        
        //Inserting notes in updateEntryStmt prepared statement
        if sqlite3_bind_text(self.updateEntryStmt, 1, (record.notes as NSString).utf8String, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateEntryStmt)")
            return
        }
        
        //Inserting notes in updateEntryStmt prepared statement
        if sqlite3_bind_int(self.updateEntryStmt, 2, Int32(record.recordId)) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateEntryStmt)")
            return
        }
        
        //executing the query to update values
        let r = sqlite3_step(self.updateEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(updateEntryStmt) \(r)")
            return
        }
    }
    
    //"DELETE FROM Records WHERE id = ?"
    func delete(recordId: Int) {
        // ensure statements are created on first usage if nil
        guard self.prepareDeleteEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.deleteEntryStmt)
        }
        
        //Inserting name in deleteEntryStmt prepared statement
        if sqlite3_bind_int(self.deleteEntryStmt, 1, Int32(recordId)) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(deleteEntryStmt)")
            return
        }
        
        //executing the query to delete row
        let r = sqlite3_step(self.deleteEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(deleteEntryStmt) \(r)")
            return
        }
    }
    
    // INSERT/CREATE operation prepared statement
    func prepareInsertEntryStmt() -> Int32 {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        let sql = "INSERT INTO Records (message, notes, date) VALUES (?,?,?)"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &insertEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
    
    // READ operation prepared statement
    func prepareReadEntryStmt() -> Int32 {
        guard readEntryStmt == nil else { return SQLITE_OK }
        let sql = "SELECT ROWID, * FROM Records WHERE ROWID = ?"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &readEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readEntryStmt")
        }
        return r
    }
    
    func prepareReadAllEntryStmt() -> Int32 {
        guard readAllEntryStmt == nil else { return SQLITE_OK }
        let sql = "SELECT ROWID, * FROM Records"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &readAllEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readAllEntryStmt")
        }
        return r
    }
    
    // UPDATE operation prepared statement
    func prepareUpdateEntryStmt() -> Int32 {
        guard updateEntryStmt == nil else { return SQLITE_OK }
        let sql = "UPDATE Records SET notes = ? WHERE ROWID = ?"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &updateEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare updateEntryStmt")
        }
        return r
    }
    
    // DELETE operation prepared statement
    func prepareDeleteEntryStmt() -> Int32 {
        guard deleteEntryStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM Records WHERE ROWID = ?"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &deleteEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
}

// Indicates an exception during an SQLite Operation.
class SqliteError : Error {
    var message = ""
    var error = SQLITE_ERROR
    init(message: String = "") {
        self.message = message
    }
    init(error: Int32) {
        self.error = error
    }
}
