//
//  SyllabusViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 7/29/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class SyllabusViewController: UIViewController {

    @IBOutlet weak var exitButton: UIView!
    @IBOutlet weak var syllabusText: UITextView!
    @IBOutlet weak var editButton: UIButton!
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    var classCode = ""
    var userType = ""
    var isEditting = false
    var customColor: UIColor? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        customColor = syllabusText.backgroundColor
        getUserType()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureExit = UITapGestureRecognizer(target: self, action:  #selector(self.popBack(sender:)))
        self.exitButton.addGestureRecognizer(gestureExit)
        
    }
    
    func getUserType(){
        let userRef = db.collection("users").document(user!)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let code: String = document.get("class_code") as! String
                self.classCode = code
                let type: String = document.get("type") as! String
                self.userType = type
                if self.userType != "teacher"{
                    self.editButton.alpha = 0
                }
                self.loadSyllabus()
            }
        }
    }
    
    @IBAction func edit(_ sender: Any) {
        if !isEditting{
            isEditting = true
            editButton.imageView?.image = nil
            editButton.setTitle("Save", for: .normal)
        syllabusText.isEditable = true
        syllabusText.textColor = .black
        syllabusText.backgroundColor = UIColor.white
        }
        else{
           isEditting = false
            editButton.setTitle("Edit", for: .normal)
           
            syllabusText.isEditable = false
            syllabusText.backgroundColor = customColor
            syllabusText.textColor = .white
            db.collection("classes").document(classCode).updateData(["syllabus": self.syllabusText.text!])
        }
    }
    
    func loadSyllabus(){
        
        
        let syllabusRef = db.collection("classes").document(classCode)
        
        syllabusRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let syllabus = document.get("syllabus") as? String
                if syllabus == ""{
                    self.editButton.imageView?.image = UIImage(named: "Add.png")
                }
                else{
                    self.syllabusText.text = syllabus
                }
            }
        }
    }
    
    @objc func popBack(sender : UITapGestureRecognizer) {
        
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
