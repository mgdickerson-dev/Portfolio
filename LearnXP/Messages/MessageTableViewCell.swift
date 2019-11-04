//
//  MessageTableViewCell.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/21/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
