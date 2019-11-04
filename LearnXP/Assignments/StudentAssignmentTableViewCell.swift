//
//  StudentAssignmentTableViewCell.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/2/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit

class StudentAssignmentTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var checkedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
