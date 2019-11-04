//
//  MultiTableViewCell.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/19/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class MultiTableViewCell: UITableViewCell {

    @IBOutlet weak var promptTextView: UITextView!
    @IBOutlet var buttons: [UIButton]!
    
    var correctAnswer = ""
    var db = Firestore.firestore()
    var currentStudent = ""
    var selectedButton:UIButton? = nil
    var questionName = ""
    var select = ""
    var userType = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func answerA(_ sender: UIButton) {
        if userType == "student"{
        selectedButton = buttons[0]
        for item in buttons{
            item.backgroundColor = UIColor(red: 191.0/255.0, green: 247.0/255.0, blue: 102.0/255.0, alpha: 1.0)
        }
        select = selectedButton?.titleLabel?.text! ?? ""
        self.db.collection("users").document(self.currentStudent).updateData([questionName : select])
        
        buttons[0].backgroundColor = .white
        }
    }
    
    @IBAction func answerB(_ sender: UIButton) {
         if userType == "student"{
        selectedButton = buttons[1]
        for item in buttons{
            item.backgroundColor = UIColor(red: 191.0/255.0, green: 247.0/255.0, blue: 102.0/255.0, alpha: 1.0)
        }
        select = selectedButton?.titleLabel?.text! ?? ""
        self.db.collection("users").document(self.currentStudent).updateData([questionName : select])
        
        buttons[1].backgroundColor = .white
        }
    }
    
    @IBAction func answerC(_ sender: UIButton) {
         if userType == "student"{
        selectedButton = buttons[2]
        for item in buttons{
            item.backgroundColor = UIColor(red: 191.0/255.0, green: 247.0/255.0, blue: 102.0/255.0, alpha: 1.0)
        }
        select = selectedButton?.titleLabel?.text! ?? ""
        self.db.collection("users").document(self.currentStudent).updateData([questionName : select])
        
        buttons[2].backgroundColor = .white
        }
    }
    
    @IBAction func answerD(_ sender: UIButton) {
         if userType == "student"{
        selectedButton = buttons[3]
        for item in buttons{
            item.backgroundColor = UIColor(red: 191.0/255.0, green: 247.0/255.0, blue: 102.0/255.0, alpha: 1.0)
        }
        select = selectedButton?.titleLabel?.text! ?? ""
        self.db.collection("users").document(self.currentStudent).updateData([questionName : select])
        
        buttons[3].backgroundColor = .white
        }
    }
    
}
