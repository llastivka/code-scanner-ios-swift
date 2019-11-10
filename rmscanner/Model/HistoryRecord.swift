//
//  HistoryRecord.swift
//  rmscanner
//
//  Created by stud on 10/11/2019.
//  Copyright © 2019 ol. All rights reserved.
//

import Foundation

struct HistoryRecord {
    var recordId : Int
    var message : String?
    var notes : String?
    var date : Date
    
    init(recordId : Int, message : String?, notes : String?, date : Date) {
        self.recordId = recordId
        self.message = message
        self.notes = notes
        self.date = date
    }
    
}
