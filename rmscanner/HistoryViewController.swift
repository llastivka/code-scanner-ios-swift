//
//  SecondViewController.swift
//  rmscanner
//
//  Created by stud on 10/11/2019.
//  Copyright © 2019 ol. All rights reserved.
//

import UIKit
import Foundation

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellReuseIdentifier = "RecordCell"
    
    @IBOutlet var historyTable: UITableView!
    
    var historyRecords : [HistoryRecord] = []
    
    class HistoryTableViewCell: UITableViewCell {
        
        @IBOutlet weak var dateLabel: UILabel!
        @IBOutlet weak var messageLabel: UILabel!
        
        @IBAction func tapEditButton(_ sender: UIButton) {
        }
        
    }
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewDidLoad()
        
        let dbManager = DBManager()
        do {
            try historyRecords = dbManager.readAll()
        } catch {
            print(error)
        }
        
//        historyTable.register(HistoryTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        historyTable.delegate = self
        historyTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! HistoryTableViewCell
        
//        let historyRecord = historyRecords[indexPath.row]
//        cell.dateLabel?.text = historyRecord.date
//        if historyRecord.notes.isEmpty {
//            cell.messageLabel?.text = historyRecord.message
//        } else {
//            cell.messageLabel?.text = historyRecord.notes
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
    }

}

