//
//  MultiAssignmentViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/16/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class MultiAssignmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numQuestions + 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < numQuestions{
            if currentStudent == "edit"{
                var cell:MultiEditTableViewCell? = nil
                
                if cellIdentifiers.count > 0{
                    cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers[indexPath.row], for: indexPath) as? MultiEditTableViewCell
                }
                else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "editCell0", for: indexPath) as? MultiEditTableViewCell
                }
                
                cell!.correctField.text = ""
                cell!.wrongField1.text = ""
                cell!.wrongField2.text = ""
                cell!.wrongField3.text = ""
                cell!.promptTextView.text = ""
                
                if questions.count > 0{
                    cell!.promptTextView.text = questions[indexPath.row]
                let assignmentRef = self.db.collection(assignmentType).document(currentAssignment)
                assignmentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let answers:[String] = document.get(self.questionNames[indexPath.row]) as! [String]
                        var i = answers.count - 2
                        for item in answers{
                            var correct = ""
                            if item.contains("$correct$"){
                                correct = item.replacingOccurrences(of: "$correct$", with: "")
                                cell!.correctField.text = correct
                            }
                            else{
                                cell!.wrongFields[i].text = item
                                i -= 1
                            }
                           
                            
                        }
                    }}}
                editCells.append(cell!)
                
                return cell!
            }
            else if currentStudent != "" && questions.count > 0{
                var cell:MultiTableViewCell? = nil
                
                if cellIdentifiers.count > 0{
                    cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers[indexPath.row], for: indexPath) as? MultiTableViewCell
                }
                else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "multiCell0", for: indexPath) as? MultiTableViewCell
                }
                for button in cell!.buttons{
                    button.backgroundColor = UIColor(red: 191.0/255.0, green: 247.0/255.0, blue: 102.0/255.0, alpha: 1.0)
                }
                cell!.promptTextView.text = questions[indexPath.row]
                cell!.currentStudent = currentStudent
                cell!.userType = userType
                
                let assignmentRef = self.db.collection(assignmentType).document(currentAssignment)
                assignmentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        var answers:[String] = document.get(self.questionNames[indexPath.row]) as! [String]
                        let studentRef = self.db.collection("users").document(self.currentStudent)
                        studentRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                cell!.select = document.get(self.questionNames[indexPath.row]) as? String ?? ""
                                cell!.questionName = self.questionNames[indexPath.row]
                                answers.shuffle()
                                var i = answers.count - 1
                                for item in answers{
                                    var correct = ""
                                    
                                    if item.contains("$correct$"){
                                        correct = item.replacingOccurrences(of: "$correct$", with: "")
                                        cell!.correctAnswer = correct
                                        cell!.buttons[i].setTitle(correct, for: .normal)
                                    }
                                    else{
                                        cell!.buttons[i].setTitle(item, for: .normal)
                                    }
                                    if cell!.select == cell!.buttons[i].currentTitle{
                                        cell!.buttons[i].backgroundColor = .white
                                        cell!.selectedButton = cell!.buttons[i]
                                    }
                                    i -= 1
                                    
                                }
                            }}
                        
                    }}
                cells.append(cell!)
                return cell!
            }
            else{
                 let cell = tableView.dequeueReusableCell(withIdentifier: "multiCell0", for: indexPath) as! MultiTableViewCell
                return cell
            }
        }
        else if indexPath.row == numQuestions && userType != "parent"{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "submitCell", for: indexPath) as! SubmitTableViewCell
            
            if userType == "teacher" && currentStudent != "edit" {
                cell.submitLabel.text = "Accept"
            }
            else if currentStudent == "edit"{
                cell.submitLabel.text = "Save"
            }
            return cell
        }
        else if indexPath.row == numQuestions + 1 && userType == "teacher" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tryAgainCell", for: indexPath) as! TryAgainTableViewCell
            
            
            if userType == "teacher" && currentStudent == "edit" {
                cell.tryAgainLabel.text = "Delete"
                cell.tryAgainLabel.textColor = .white
                cell.tryAgainLabel.backgroundColor = .red
                
            }
            return cell
        }
        else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == numQuestions{
            if userType == "student"{
                let i = numQuestions
                var numberCorrect = 0
                for cell in cells{
                    if cell.selectedButton?.titleLabel?.text == cell.correctAnswer{
                        numberCorrect += 1
                        cell.selectedButton?.backgroundColor = .green
                    }
                    else{
                        cell.selectedButton?.backgroundColor = .red
                    }
                }
                
                if completed == false && numberCorrect == i{
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
                    
                    self.navigationController?.popViewController(animated: true)
                }
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
            else if currentStudent == "edit"{
                    
                    
                    for cell in editCells{
                        
                        
                        
                        var answers: [String] = []
                        var assignment = "\(cell.promptTextView.text ?? "")\(NSDate().timeIntervalSince1970)"
                        assignment = assignment.replacingOccurrences(of: "/", with: "")
                        assignment = assignment.replacingOccurrences(of: "\\", with: "")
                        assignment = assignment.replacingOccurrences(of: ".", with: "")
                        assignment = assignment.replacingOccurrences(of: " ", with: "")
                        
                        questionNames.append(assignment)
                        questions.append(cell.promptTextView.text)
                        answers.append("$correct$\(cell.correctField.text!)")
                        answers.append(cell.wrongField1.text!)
                        answers.append(cell.wrongField2.text!)
                        answers.append(cell.wrongField3.text!)
                        db.collection(self.assignmentType).document(self.currentAssignment).updateData([assignment : answers])
                    }
                    db.collection(self.assignmentType).document(self.currentAssignment).updateData(["questions" : questions])
                    db.collection(self.assignmentType).document(self.currentAssignment).updateData(["question_names" : questionNames])
                    
                    
                    self.navigationController?.popViewController(animated: true)
            }
        }
        else if indexPath.row == numQuestions + 1{
            if userType == "teacher" && currentStudent == "edit"{
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
            else if !gradedStudents.contains(currentStudent) {
                
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
        }
    
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
    var numQuestions = 0
    var cellIdentifiers:[String] = []
    var editCells: [MultiEditTableViewCell] = []
    var cells: [MultiTableViewCell] = []
    var questions: [String] = []
    var questionNames: [String] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        setUp()
        reloadInputViews()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func setUp(){
        if currentAssignment != ""{
            let assignmentRef = self.db.collection(assignmentType).document(currentAssignment)
            assignmentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.titleLabel.text = document.get("title") as? String
                    self.numQuestions = document.get("number_questions") as! Int
                    self.reward = (document.get("reward") as? Int)!
                    self.gradedStudents = document.get("graded_student") as? [String] ?? []
                    self.questions = document.get("questions") as? [String] ?? []
                    self.questionNames = document.get("question_names") as? [String] ?? []
                    let studentsCompleted = document.get("students_completed") as? [String]
                    
                    for item in studentsCompleted!{
                        if item == self.user{
                            self.completed = true
                        }
                    }
                    for i in 0...self.numQuestions - 1{
                        if self.currentStudent == "edit"{
                        self.cellIdentifiers.append("editCell\(i)")
                        }
                        else{
                        self.cellIdentifiers.append("multiCell\(i)")
                        }
                    }
                    self.cells = []
                    self.tableView.reloadData()
                }}}
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
