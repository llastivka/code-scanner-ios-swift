//
//  ViewController.swift
//  rmscanner
//
//  Created by stud on 10/11/2019.
//  Copyright © 2019 ol. All rights reserved.
//

import UIKit
import os.log

class ResultViewController: UIViewController {
    
    @IBOutlet weak var resultText: UILabel!
    
    let oslog = OSLog(subsystem: "rmscanner", category: "resultscreen")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (resultText.text != nil && !(resultText.text?.isEmpty)!) {
            let dbManager = DBManager()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            let dateString = formatter.string(from: date)
            let record = HistoryRecord(recordId: 1, message: resultText.text!, notes: "", date: dateString)
            dbManager.create(record: record)
            
            let preferences = UserDefaults.standard
            let autoNavigationKey = "auto"
            if preferences.object(forKey: autoNavigationKey) == nil {
                os_log("Failed to retreive auto navigation settings.")
            } else {
                let autoNavigationSetting = preferences.bool(forKey: autoNavigationKey)
                os_log("Auto navigation was set to %@.", autoNavigationSetting.description)
                if autoNavigationSetting {
                    navigateToBrowser()
                }
            }
            
        }
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
    
    @IBAction func navigateButtonClicked(_ sender: UIButton) {
        navigateToBrowser()
    }
    
    func navigateToBrowser() {
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
