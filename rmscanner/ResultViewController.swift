//
//  ViewController.swift
//  rmscanner
//
//  Created by stud on 10/11/2019.
//  Copyright © 2019 ol. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var resultText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let dbManager = DBManager()
        let record = HistoryRecord(recordId: 1, message: resultText.text!, notes: "notes", date: "2019-11-24")
        dbManager.create(record: record)
    }
    
    
    @IBAction func copyResult(_ sender: UIButton) {
        UIPasteboard.general.string = resultText.text;
    }
    
    @IBAction func shareResult(_ sender: UIButton) {
        let textToShare = [ resultText.text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func navigateToBrowser(_ sender: UIButton) {
        var url = ""
        let result = resultText.text!
        if (result.contains("http")) {
            url = resultText.text!
        } else {
            url = "http://www.google.com/search?q=" + result ;
        }
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
