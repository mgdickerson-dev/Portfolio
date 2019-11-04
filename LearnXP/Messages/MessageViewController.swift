//
//  MessageViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/21/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var students:[String] = []
    var message = ""
    var subject = ""
    var target = ""
    var messages:[Int] = []
    var numMessage = 0
    var user = Auth.auth().currentUser?.uid
    var db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        inputTextView.delegate = self
        bodyTextView.text = message
        titleLabel.text = subject
        inputTextView.becomeFirstResponder()
        subject = "^\(NSDate().timeIntervalSince1970)^\(subject)"
        
        subject = subject.replacingOccurrences(of: ".", with: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func textView(_ textView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textViewText = textView.text,
            let rangeOfTextToReplace = Range(range, in: textViewText) else {
                return false
        }
        let substringToReplace = textViewText[rangeOfTextToReplace]
        let count = textViewText.count - substringToReplace.count + string.count
        
        return count <= 500
    }
    
    @IBAction func send(_ sender: Any) {
        if inputTextView.text != ""{
            if target == "all"{
                var i = 0
                
                let dispatchGroup = DispatchGroup()
                let dispatchQueue = DispatchQueue(label: "i")
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                
                dispatchQueue.async {
                    for item in self.students{
                        let studentRef = self.db.collection("users").document(item)
                    studentRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            dispatchGroup.enter()
                            var array:[String] = document.get(self.user as Any) as? [String] ?? []
                            array.append(self.subject)
                            studentRef.updateData([self.user : array])
                        
                            self.db.collection("users").document(item).updateData([self.subject : self.inputTextView.text!])
                            self.db.collection("users").document(item).updateData(["number_messages" : self.messages[i] + 1])
                    i += 1
                            
                        }
                
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                        }
                
                dispatchSemaphore.wait()
                    }
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
        }
        else{
           let studentRef = db.collection("users").document(target)
                studentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        var array:[String] = document.get(self.user as Any) as? [String] ?? []
                        array.append(self.subject)
                        studentRef.updateData([self.user : array])
                    
                        studentRef.updateData([self.subject : self.inputTextView.text!])
                        studentRef.updateData(["number_messages" : self.numMessage + 1])
                        
                        self.navigationController?.popViewController(animated: true)
                        
                    }}}}
    }
    
    @IBAction func close(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
