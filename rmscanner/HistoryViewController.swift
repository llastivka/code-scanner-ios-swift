//
//  SecondViewController.swift
//  rmscanner
//
//  Created by stud on 10/11/2019.
//  Copyright © 2019 ol. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellReuseIdentifier = "cell"
    
    @IBOutlet var historyTable: UITableView!
    
    var historyRecords : [HistoryRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyRecords = DBManager.shared.loadHistory()
        
        historyTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        historyTable.delegate = self
        historyTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = historyTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! UITableViewCell
        
        cell.textLabel?.text = historyRecords[indexPath.row].message
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//
//        let currentRecord = historyRecords[indexPath.row]
//
//        cell.textLabel?.text = currentRecord.message
//        cell.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
//
//        let sessionConfiguration = URLSessionConfiguration.default
//        let session = URLSession(configuration: URLSessionConfiguration.default)
//        let task = session.dataTask(with: URL(string: currentRecord.coverURL)!) { (imageData, response, error) in
//            if let data = imageData {
//                DispatchQueue.main.async {
//                    cell.imageView?.image = UIImage(data: data)
//                    cell.layoutSubviews()
//                }
//            }
//        }
//        task.resume()
//
//        return cell
//    }


}

