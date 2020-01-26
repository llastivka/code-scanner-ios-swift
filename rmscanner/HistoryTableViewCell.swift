//
//  HistoryTableViewCell.swift
//  rmscanner
//
//  Created by stud on 26/01/2020.
//  Copyright © 2020 ol. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func tapToEdit(_ sender: UIButton) {
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
