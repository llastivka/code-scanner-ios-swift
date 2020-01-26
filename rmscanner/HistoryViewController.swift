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
    
    
    @IBOutlet var historyTable: UITableView!
    
    let cellReuseIdentifier = "cell"
    
    var db:DBManager = DBManager()
    
    var historyRecords : [HistoryRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTable.register(HistoryTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        historyTable.delegate = self
        historyTable.dataSource = self
        
        historyRecords = db.read()
        historyTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return historyRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! HistoryTableViewCell
        
        let historyRecord = historyRecords[indexPath.row]
        cell.dateLabel?.text = historyRecord.date
        if historyRecord.notes.isEmpty {
            cell.messageLabel?.text = historyRecord.message
        } else {
            cell.messageLabel?.text = historyRecord.notes
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            
            self.historyTable.reloadData()
        }
    }

}

