//
//  AssignmentViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/1/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class AssignmentViewController: UIViewController, UITextViewDelegate {

    var currentAssignment = ""
    var classCode = ""
    var currentStudent = ""
    var assignmentType = ""
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    var userType = ""
    var completed = false
    var reward = 0
    var gradedStudents: [String] = []
    var students:[String] = []
    
    @IBOutlet weak var submissionTextView: UITextView!
    @IBOutlet weak var promptTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        setUp()
        reloadInputViews()
        if currentStudent != "edit"{
            saveButton.alpha = 0
        }
        if userType == "teacher" && currentStudent != "edit" {
            submitButton.setTitle("Accept", for: .normal)
        }
        else if userType != "teacher"{
            tryAgainButton.alpha = 0
        }
        if userType == "parent"{
            submitButton.alpha = 0
            submissionTextView.isEditable = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submissionTextView.delegate = self
        promptTextView.delegate = self
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func save(_ sender: Any) { db.collection(assignmentType).document(currentAssignment).updateData(["body" : promptTextView.text!])
        self.navigationController?.popViewController(animated: true)
    }
    
    func setUp(){
        completed = false
        if currentAssignment != ""{
            let assignmentRef = self.db.collection(assignmentType).document(currentAssignment)
            assignmentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.titleLabel.text = document.get("title") as? String
                    self.promptTextView.text = document.get("body") as? String
                    self.reward = (document.get("reward") as? Int)!
                    self.gradedStudents = document.get("graded_student") as? [String] ?? []
                    let studentsCompleted = document.get("students_completed") as? [String]
                    for item in studentsCompleted!{
                        if item == self.user{
                            self.completed = true
                        }
                    }
                }}
            if currentStudent != "" && currentStudent != "edit"{
                let studentRef = self.db.collection("users").document(currentStudent)
                studentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if document.get(self.currentAssignment) != nil{
                            self.submissionTextView.text = document.get(self.currentAssignment) as? String
                        }
                    }}
            }
            else if userType == "student"{
                submissionTextView.becomeFirstResponder()
                let studentRef = self.db.collection("users").document(user!)
                studentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if document.get(self.currentAssignment) != nil{
                            self.submissionTextView.text = document.get(self.currentAssignment) as? String
                        }
                    }}
            }
            else if userType != "student"{
                submissionTextView.isEditable = false
            }
            if userType == "teacher" && currentStudent == "edit"{
                promptTextView.isEditable = true
                promptTextView.backgroundColor = .white
                promptTextView.textColor = .black
                promptTextView.becomeFirstResponder()
                submitButton.setTitle("Delete", for: .normal)
                submitButton.backgroundColor = .red
                submitButton.setTitleColor(.white, for: .normal)
                tryAgainButton.alpha = 0
            }
        }
    }
    
    @IBAction func close(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        if userType == "student"{
            if completed == false{
            let assignmentRef = self.db.collection(assignmentType).document(currentAssignment)
            assignmentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    var studentsCompleted = document.get("students_completed") as? [String]
                    studentsCompleted?.append(self.user!)
                    assignmentRef.updateData(["students_completed": studentsCompleted!])
                }}
                let userRef = self.db.collection("users").document(user!)
                userRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let completed = document.get("assignments_completed") as? Int
                        userRef.updateData(["assignments_completed": completed! + 1]);
                    }}
            }
            db.collection("users").document(user!).updateData([self.currentAssignment: self.submissionTextView.text!]);
            
            self.navigationController?.popViewController(animated: true)
        }
        if userType == "teacher" && !gradedStudents.contains(currentStudent) && currentStudent != "edit"
        {
            let studentRef = self.db.collection("users").document(self.currentStudent)
            studentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    var experience: Int = document.get("experience") as! Int
                    experience += self.reward
                    if experience >= 0{ self.db.collection("users").document(self.currentStudent).updateData(["experience" : experience])
                    }
                    else{
                        self.db.collection("users").document(self.currentStudent).updateData(["experience" : 0])
                        
                        
                    }
                    self.gradedStudents.append(self.currentStudent)
                    self.db.collection(self.assignmentType).document(self.currentAssignment).updateData(["graded_student" : self.gradedStudents])
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        else if userType == "teacher" && currentStudent == "edit"{
            let assignmentRef = db.collection(assignmentType).document(currentAssignment)
            
            assignmentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let completed = document.get("students_completed") as! [String]
                    for item in self.students{
                        if completed.contains(item){
                            let studentRef = self.db.collection("users").document(item)
                            studentRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let numComplete = document.get("assignments_completed") as! Int
                                    studentRef.updateData(["assignments_completed" : numComplete - 1])
                                }}
                        }
                    }
            assignmentRef.delete()
                }}
            
            let classRef = db.collection("classes").document(classCode)
            
            classRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    var assignmentArray = document.get(self.assignmentType) as! [String]
                    let total = document.get("total_assignments") as! Int
                    assignmentArray.removeAll{$0 == self.currentAssignment}
                    classRef.updateData([self.assignmentType: assignmentArray])
                    classRef.updateData(["total_assignments": total - 1])
                    self.performSegue(withIdentifier: "unwind", sender: nil)
                }}
        }
    }
    
    @IBAction func tryAgain(_ sender: Any) {
        if !gradedStudents.contains(currentStudent) {
            
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "tryagain")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        dispatchQueue.async {
            dispatchGroup.enter()
            let assignmentRef = self.db.collection(self.assignmentType).document(self.currentAssignment)
        assignmentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let studentsCompleted = document.get("students_completed") as? [String]
                let new = studentsCompleted!.filter { $0 != self.currentStudent }
                assignmentRef.updateData(["students_completed": new])
            }}
            let studentRef = self.db.collection("users").document(self.currentStudent)
        studentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                let completed = document.get("assignments_completed") as? Int
                studentRef.updateData(["assignments_completed": completed! - 1]);
            
                self.navigationController?.popViewController(animated: true)
            }}
            dispatchGroup.leave()
            dispatchSemaphore.signal()
        }
        dispatchGroup.wait()
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
