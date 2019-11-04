//
//  MultiEditTableViewCell.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/19/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit

class MultiEditTableViewCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var promptTextView: UITextView!
    @IBOutlet weak var correctField: UITextField!
    @IBOutlet weak var wrongField1: UITextField!
    @IBOutlet weak var wrongField2: UITextField!
    @IBOutlet weak var wrongField3: UITextField!
    @IBOutlet var wrongFields: [UITextField]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        correctField.delegate = self
        wrongField1.delegate = self
        wrongField2.delegate = self
        wrongField3.delegate = self
        promptTextView.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
            return count <= 50
    }
    func textView(_ textView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textViewText = textView.text,
            let rangeOfTextToReplace = Range(range, in: textViewText) else {
                return false
        }
        let substringToReplace = textViewText[rangeOfTextToReplace]
        let count = textViewText.count - substringToReplace.count + string.count
        
        return count <= 100
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
        case correctField:
            wrongField1.becomeFirstResponder()
            break
        case wrongField1:
            wrongField2.becomeFirstResponder()
            break
        case wrongField2:
            wrongField3.becomeFirstResponder()
            break
        case wrongField3:
            wrongField3.resignFirstResponder()
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
