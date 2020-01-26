//
//  SettingsViewController.swift
//  rmscanner
//
//  Created by stud on 30/11/2019.
//  Copyright © 2019 ol. All rights reserved.
//

import Foundation
import UIKit
import os.log

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var autoNavSwitch: UISwitch!
    let oslog = OSLog(subsystem: "rmscanner", category: "settings")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        let autoNavigationKey = "auto"
        if preferences.object(forKey: autoNavigationKey) == nil {
            os_log("Failed to retreive auto navigation settings.")
        } else {
            let autoNavigationSetting = preferences.bool(forKey: autoNavigationKey)
            os_log("Auto navigation was set to %@.", autoNavigationSetting.description)
            if !autoNavigationSetting {
                autoNavSwitch.isOn = false;
            }
        }
    }
    
    @IBAction func setAutomaticNavigation(_ sender: UISwitch) {
        var autoValue : Bool
        if (sender.isOn) {
            autoValue = true
        } else {
            autoValue = false
        }
        
        let preferences = UserDefaults.standard
        let currentLevelKey = "auto"
        preferences.set(autoValue, forKey: currentLevelKey)
        
        let didSave = preferences.synchronize()
        if didSave {
            os_log("Auto navigation is set to %@.", autoValue.description)
        } else {
            os_log("Failed to save auto navigation settings.")
        }
    }
    
}
