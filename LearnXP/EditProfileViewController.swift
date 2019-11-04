//
//  EditProfileViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/7/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    var first: String = ""
    var last:String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        errorLabel.alpha = 0
        populateUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showError(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func populateUser(){
        let userRef = db.collection("users").document((user?.uid)!)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.first = document.get("first_name") as! String
                self.last = document.get("last_name") as! String
                self.firstNameField.text = self.first
                self.lastNameField.text = self.last
            }}
    }
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        if(firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
            showError("Please fill out all fields")
        }
        else{
            db.collection("users").document((user?.uid)!).updateData(["first_name": firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? first])
            db.collection("users").document((user?.uid)!).updateData(["last_name": lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? last])
            
            self.navigationController?.popViewController(animated: true)
        }
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
