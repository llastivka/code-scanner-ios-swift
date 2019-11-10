//
//  DBManager.swift
//  rmscanner
//
//  Created by stud on 10/11/2019.
//  Copyright © 2019 ol. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    
    static let shared: DBManager = DBManager()
    
    let databaseFileName = "database.sqlite"
    
    let fieldRecordId = "recordId"
    let fieldMessage = "message"
    let fieldNotes = "notes"
    let fieldDate = "date"
    
    var pathToDatabase: String!
    
    var database: FMDatabase!
    
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
    }
    
    func createDatabase() -> Bool {
        var created = false
        
        if !FileManager.default.fileExists(atPath: pathToDatabase) {
            database = FMDatabase(path: pathToDatabase!)
            
            if database != nil {
                // Open the database.
                if database.open() {
                    
                    let createHistoryTableQuery = "create table history (\(fieldRecordId) integer primary key autoincrement not null, \(fieldMessage) text not null, \(fieldNotes) text, \(fieldDate) date not null)"
                    
                    do {
                        try database.executeUpdate(createHistoryTableQuery, values: nil)
                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }

                    database.close()
                }
                else {
                    print("Could not open the database.")
                }
            }
            
        }
        
        return created
    }
    
    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
            }
        }
        
        if database != nil {
            if database.open() {
                return true
            }
        }
        
        return false
    }
    
    func loadHistory() -> [HistoryRecord]! {
        var historyRecords: [HistoryRecord]!
        
        if openDatabase() {
            let query = "select * from history order by \(fieldDate) desc"
            
            do {
                print(database)
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    let historyRecord = HistoryRecord(recordId: Int(results.int(forColumn: fieldRecordId)),
                                          message: results.string(forColumn: fieldMessage),
                                          notes: results.string(forColumn: fieldNotes),
                                          date: results.date(forColumn: fieldDate)!
                    )
                    
                    if historyRecords == nil {
                        historyRecords = [HistoryRecord]()
                    }
                    
                    historyRecords.append(historyRecord)
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        
        return historyRecords
    }
    
    func insertHistoryData() {
        let historyRecord1 = HistoryRecord(recordId: 1, message: "Message1", notes: "", date: Date())
        let historyRecord2 = HistoryRecord(recordId: 3, message: "Message2", notes: "", date: Date())
        let historyData = [historyRecord1, historyRecord2]
        
        
        if openDatabase() {
            var query = ""
            do {
                for record in historyData {
                    
                    query += "insert into history (\(fieldRecordId), \(fieldMessage), \(fieldNotes), \(fieldDate)) values (null, '\(record.message!)', '\(record.notes!)', \(record.date));"
                }
                
                if !database.executeStatements(query) {
                    print("Failed to insert initial data into the database.")
                    print(database.lastError(), database.lastErrorMessage())
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
    }

}
