//
//  TeacherProfileViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/7/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class TeacherProfileViewController: UIViewController {

    var classCode = ""
    let db = Firestore.firestore()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        populateTeacher()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func populateTeacher(){
        let teacherRef = db.collection("users").document(classCode)
        teacherRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let first: String = document.get("first_name") as! String
                let last: String = document.get("last_name") as! String
                let school: String = document.get("school_name") as! String
                let email: String = document.get("email") as! String
                
                self.classLabel.text = "Class: \(self.classCode)"
                self.schoolLabel.text = "School: \(school)"
                self.nameLabel.text = "Name: \(first) \(last)"
                self.emailLabel.text = "Email: \(email)"
                
            }}
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
